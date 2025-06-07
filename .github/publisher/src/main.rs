use anyhow::{anyhow, Context, Result};
use petgraph::algo::toposort;
use petgraph::graph::DiGraph;
use petgraph::visit::Dfs;
use std::collections::{BTreeMap, HashMap, HashSet};
use std::env;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use toml_edit::DocumentMut;

fn main() -> Result<()> {
    if env::var("FORC_PUB_TOKEN").is_err() {
        return Err(anyhow!(
            "Error: FORC_PUB_TOKEN environment variable is not set."
        ));
    }

    let args: Vec<String> = env::args().skip(1).collect();
    if args.is_empty() {
        println!("No projects specified for publishing. Exiting.");
        return Ok(());
    }
    let seed_projects: HashSet<String> = args.into_iter().collect();

    let standards_dir = env::current_dir()?.join("standards");
    let project_paths = find_sway_projects(&standards_dir)?;

    let mut all_packages_data: BTreeMap<String, (DocumentMut, PathBuf)> = BTreeMap::new();
    let mut graph = DiGraph::new();
    let mut node_map = HashMap::new();

    for path in &project_paths {
        let project_name_from_path = path
            .file_name()
            .and_then(|s| s.to_str())
            .context("Could not get project name from path")?
            .to_string();
        let toml_path = path.join("Forc.toml");
        let toml_content = fs::read_to_string(&toml_path)
            .with_context(|| format!("Failed to read Forc.toml for {}", project_name_from_path))?;
        let forc_toml: DocumentMut = toml_content
            .parse::<DocumentMut>()
            .with_context(|| format!("Failed to parse Forc.toml for {}", project_name_from_path))?;

        let project_name_from_toml = forc_toml["project"]["name"]
            .as_str()
            .context("Could not get project name from Forc.toml")?
            .to_string();

        let node = graph.add_node(project_name_from_toml.clone());
        node_map.insert(project_name_from_toml, node);
        all_packages_data.insert(project_name_from_path, (forc_toml, toml_path));
    }

    for (project_name, (forc_toml, _)) in &all_packages_data {
        if let Some(dependencies) = forc_toml.get("dependencies").and_then(|d| d.as_table()) {
            let from_node = node_map[project_name];
            for (dep_name, dep) in dependencies.iter() {
                if let Some(dep_table) = dep.as_inline_table() {
                    if dep_table.contains_key("path") {
                        if let Some(&to_node) = node_map.get(dep_name) {
                            graph.add_edge(to_node, from_node, ());
                        }
                    }
                }
            }
        }
    }

    // Find all projects that need to be published based on the seed projects.
    let mut to_publish_names = HashSet::new();
    for seed_name in &seed_projects {
        if !node_map.contains_key(seed_name) {
            println!(
                "Warning: Specified project '{}' not found. Skipping.",
                seed_name
            );
            continue;
        }
        let start_node = node_map[seed_name];
        // DFS from the seed node finds all projects that depend on it.
        let mut dfs = Dfs::new(&graph, start_node);
        while let Some(nx) = dfs.next(&graph) {
            to_publish_names.insert(graph[nx].clone());
        }
    }

    if to_publish_names.is_empty() {
        println!("No projects to publish after analyzing dependencies.");
        return Ok(());
    }

    let sorted_indices = toposort(&graph, None).map_err(|cycle| {
        let node_index = cycle.node_id();
        let project_name = graph.node_weight(node_index).unwrap();
        anyhow!(
            "A cycle was detected in the dependency graph involving '{}'",
            project_name
        )
    })?;

    let sorted_projects: Vec<String> = sorted_indices
        .iter()
        .map(|&i| graph[i].clone())
        .filter(|p| to_publish_names.contains(p))
        .collect();

    if sorted_projects.is_empty() {
        println!("No projects to publish after filtering and sorting.");
        return Ok(());
    }

    println!("Publishing order determined:");
    println!(" -> {}", sorted_projects.join(" -> "));
    println!("{}", "-".repeat(30));

    for project_name in sorted_projects {
        println!("Publishing {}...", project_name);
        let project_dir = standards_dir.join(&project_name);

        let output = Command::new("forc")
            .arg("publish")
            .arg("--registry-url")
            .arg("http://localhost:8080")
            .current_dir(&project_dir)
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .output()
            .context("Failed to execute 'forc publish'")?;

        let stderr = String::from_utf8_lossy(&output.stderr);

        if !output.status.success() {
            if stderr.contains("already exists") {
                println!("{} version already published, skipping.", project_name);
            } else {
                eprintln!("Error publishing {}:", project_name);
                eprintln!("{}", stderr);
                return Err(anyhow!("Failed to publish {}", project_name));
            }
        } else {
            println!("Successfully published {}", project_name);
        }

        // Clone the version string to release the immutable borrow on `all_packages_data`,
        // allowing us to pass it mutably to `update_dependents`.
        let published_version = all_packages_data[project_name.as_str()]
            .0["project"]["version"]
            .as_str()
            .context("Could not find project version in Forc.toml")?
            .to_string();
        update_dependents(&project_name, &published_version, &mut all_packages_data)?;
    }

    println!("{}", "-".repeat(30));
    println!("All standards published successfully!");

    Ok(())
}

fn find_sway_projects(directory: &Path) -> Result<Vec<PathBuf>> {
    let mut projects = vec![];
    for entry in fs::read_dir(directory)? {
        let entry = entry?;
        let path = entry.path();
        if path.is_dir() && entry.file_name().to_string_lossy().starts_with("src") {
            projects.push(path);
        }
    }
    Ok(projects)
}

fn update_dependents(
    published_package_name: &str,
    published_version: &str,
    all_packages_data: &mut BTreeMap<String, (DocumentMut, PathBuf)>,
) -> Result<()> {
    for (package_name, (data, toml_path)) in all_packages_data.iter_mut() {
        let mut dirty = false;
        if let Some(dep) = data["dependencies"].get_mut(published_package_name) {
            if let Some(dep_table) = dep.as_inline_table_mut() {
                if dep_table.get("path").is_some() {
                    println!(
                        "Updating dependency '{}' in {}'s Forc.toml",
                        published_package_name, package_name
                    );
                    dep_table.remove("path");
                    dep_table.insert("version", published_version.into());
                    dirty = true;
                }
            }
        }

        if dirty {
            let new_toml_content = data.to_string();
            fs::write(toml_path, new_toml_content).with_context(|| {
                format!("Failed to write updated Forc.toml for {}", package_name)
            })?;
        }
    }
    Ok(())
}
