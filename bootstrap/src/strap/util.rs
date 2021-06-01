use std::env;
use std::path::{Path, PathBuf};

use anyhow::Result;

pub struct StackDir {
    original_dir: PathBuf,
}

impl StackDir {
    pub fn new<P: AsRef<Path>>(target: P) -> Result<StackDir> {
        let original_dir = env::current_dir()?;
        env::set_current_dir(target)?;
        Ok(Self { original_dir })
    }
}

impl Drop for StackDir {
    fn drop(&mut self) {
        if let Err(e) = env::set_current_dir(&self.original_dir) {
            eprintln!("error dropping stackdir: {}", e);
        }
    }
}
