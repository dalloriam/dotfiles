use std::collections::HashMap;
use std::fs;
use std::io::{stdin, stdout, Write};
use std::path::{Path, PathBuf};

use anyhow::{anyhow, Context, Result};

use futures::StreamExt;

use menmos_client::{Client, Config, Profile};

use tokio::io::AsyncWriteExt;

const MENMOS_BLOBS_CONFIG: &str = "data/menmos_blobs.json";

fn prompt(msg: &str) -> Result<String> {
    print!("? {}: ", msg);
    let mut user_input = String::new();
    stdout().flush()?;
    stdin().read_line(&mut user_input)?;

    Ok(String::from(user_input.trim()))
}

fn create_default_profile(mut config: Config) -> Result<()> {
    let host = prompt("host")?;
    let username = prompt("username")?;
    let password = prompt("password")?;

    config.add(
        "default",
        Profile {
            host,
            username,
            password,
        },
    )?;

    Ok(())
}

fn load_blob_config(dotfiles_dir: &Path) -> Result<HashMap<String, PathBuf>> {
    let config_path = dotfiles_dir.join(MENMOS_BLOBS_CONFIG);
    let f = fs::File::open(&config_path).context(format!("missing {:?}", &config_path))?;

    let m: HashMap<String, PathBuf> = serde_json::from_reader(f)?;

    Ok(m.into_iter()
        .map(|(k, v)| (k, dotfiles_dir.join(v)))
        .collect())
}

pub async fn menmos(dotfiles_dir: &Path) -> Result<()> {
    // TODO: It'd be nice if menmos could use the same auth as the rest of the cloud.
    println!("[menmos]");

    // Try to load a menmos config to see if configured.
    let config = Config::load()?;
    if !config.profiles.contains_key("default") {
        // If not configured, we want to create a default profile.
        create_default_profile(config)?;
    }

    let client = Client::new_with_profile("default").await?;

    for (blob_id, destination) in load_blob_config(dotfiles_dir)? {
        let metadata = client.get_meta(&blob_id).await?;

        let metadata = match metadata {
            Some(m) => m,
            None => {
                eprintln!("missing metadata for blob ID: {}", &blob_id);
                continue;
            }
        };

        if !destination.exists() {
            tokio::fs::create_dir_all(&destination).await?;
        }

        let dest_file = destination.join(&metadata.name);

        let stream = client.get_file(&blob_id).await?;
        let mut stream_pin = Box::pin(stream);
        let mut f = tokio::fs::File::create(&dest_file).await?;

        while let Some(chunk) = stream_pin.next().await {
            match chunk {
                Ok(c) => f.write_all(c.as_ref()).await?,
                Err(e) => {
                    tokio::fs::remove_file(&dest_file).await?;
                    return Err(anyhow!("{}", e.to_string()));
                }
            }
        }

        println!("{} -> {}", &blob_id, &metadata.name);
    }

    Ok(())
}
