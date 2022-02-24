use std::path::Path;

use anyhow::Result;

#[cfg(unix)]
pub fn symlink(from: &Path, to: &Path) -> Result<()> {
    use std::os::unix;
    unix::fs::symlink(from, to)?;
    Ok(())
}

#[cfg(windows)]
pub fn symlink(from: &Path, to: &Path) -> Result<()> {
    use anyhow::ensure;
    use std::os::windows;

    ensure!(from.is_file(), "source path cannot be a directory");
    windows::fs::symlink_file(from, to)?;
    Ok(())
}
