use anyhow::Result;
use clap::Clap;
use strap::Target;

const VERSION: &str = env!("CARGO_PKG_VERSION");

#[derive(Clap)]
pub enum Action {
    /// Apply all available configuration steps.
    #[clap(name = "all")]
    All,

    /// Apply a single configuration step.
    #[clap(name = "apply")]
    Apply { tgt: Target },
}

#[derive(Clap)]
#[clap(version = VERSION, author = "William Dussault")]
struct Options {
    #[clap(subcommand)]
    action: Action,
}

impl Options {
    pub fn execute(self) -> Result<()> {
        match self.action {
            Action::All => strap::all(),
            Action::Apply { tgt } => strap::single(tgt),
        }
    }
}

fn main() {
    if let Err(e) = Options::parse().execute() {
        eprintln!("! Error: {}", e);
    }
}
