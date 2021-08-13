use std::fs;
use std::io::{stdin, stdout, Write};
use std::path::{Path, PathBuf};

use anyhow::{anyhow, Result};

use serde::{Deserialize, Serialize};

#[derive(Deserialize, Serialize)]
struct Credentials {
    pub email: String,
    pub password: String,
}

fn get_cloud_config_path() -> Result<PathBuf> {
    let cfg_dir = dirs::config_dir().ok_or_else(|| anyhow!("missing config directory"))?;
    Ok(cfg_dir.join("dalloriam").join("cloud.json"))
}

fn prompt(msg: &str) -> Result<String> {
    print!("? {}: ", msg);
    let mut user_input = String::new();
    stdout().flush()?;
    stdin().read_line(&mut user_input)?;

    Ok(String::from(user_input.trim()))
}

pub fn cloud(_dotfiles_dir: &Path) -> Result<()> {
    println!("[cloud]");

    let cfg_path = get_cloud_config_path()?;

    if cfg_path.exists() {
        println!("cloud configuration file already exists");
        return Ok(());
    }

    let email = prompt("cloud email")?;
    let password = prompt("cloud password")?;

    let creds = Credentials { email, password };
    let f = fs::File::create(&cfg_path)?;

    serde_json::to_writer_pretty(f, &creds)?;

    Ok(())
}
