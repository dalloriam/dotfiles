use std::fs;
use std::{io::Read, path::Path};

use anyhow::{ensure, Result};

const PACKAGES_FILE: &str = "data/binman_packages.txt";

fn read_packages_file(path: &Path) -> Result<Vec<String>> {
    let mut f = fs::File::open(path)?;

    let mut buf = String::new();
    f.read_to_string(&mut buf)?;

    Ok(buf.lines().map(String::from).collect())
}

pub async fn binman_packages(dotfiles_dir: &Path) -> Result<()> {
    println!("[binman]");

    let packages_fullpath = dotfiles_dir.join(PACKAGES_FILE);

    ensure!(packages_fullpath.exists(), "packages file doesn't exist");

    let packages = read_packages_file(&packages_fullpath)?;

    for package in packages {
        if let Err(e) = binlib::install_target(&package, "latest", None).await {
            if e.to_string().contains("already installed") {
                println!("{} is already installed", package);
                continue;
            }
            // TODO: prompt to continue
            eprintln!("error intalling {package}: {e}");
        }
    }

    Ok(())
}
