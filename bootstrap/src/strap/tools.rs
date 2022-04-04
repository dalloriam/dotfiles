use std::env::consts::OS;
use std::ffi::OsString;
use std::fs;
use std::path::{Path, PathBuf};

use anyhow::Result;

use super::util;

const TOOLS_SRC_DIR: &str = "tools";
const DST_DIR: &str = "~/bin";

fn is_installable(file_name: &OsString) -> Option<String> {
    let name_str = file_name.to_string_lossy().to_string();
    if name_str.contains('_') {
        if name_str.starts_with(OS) {
            Some(String::from(
                name_str.strip_prefix(&format!("{}_", OS)).unwrap(),
            ))
        } else {
            None
        }
    } else {
        Some(name_str)
    }
}

pub fn tools(dotfiles_dir: &Path) -> Result<()> {
    println!("[tools]");

    let src_path = dotfiles_dir.join(TOOLS_SRC_DIR);
    let dst_dir = PathBuf::from(shellexpand::tilde(DST_DIR).to_string());

    if !dst_dir.exists() {
        fs::create_dir_all(&dst_dir)?;
    }

    for file in fs::read_dir(src_path)?.filter_map(|f| f.ok()) {
        let tgt_name = match is_installable(&file.file_name()) {
            Some(fname) => fname,
            None => {
                println!("! [SKIP] {}", file.file_name().to_string_lossy());
                continue;
            }
        };

        let dst_path = dst_dir.join(tgt_name);
        if dst_path.exists() {
            fs::remove_file(&dst_path)?;
        }

        util::symlink(&file.path(), &dst_path)?;
        println!("- {}", dst_path.to_string_lossy());
    }

    Ok(())
}
