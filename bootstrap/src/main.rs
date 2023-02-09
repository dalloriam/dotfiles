use anyhow::Result;
use clap::Parser;
use strap::Target;

const VERSION: &str = env!("CARGO_PKG_VERSION");

#[derive(Parser)]
pub enum Action {
    /// Apply all available configuration steps.
    #[clap(name = "all")]
    All {
        #[clap(short = 'i')]
        interactive: bool,
    },

    /// Apply a single configuration step.
    #[clap(name = "apply")]
    Apply { tgt: Vec<Target> },

    /// List available steps.
    #[clap(name = "list")]
    List,
}

#[derive(Parser)]
#[clap(version = VERSION, author = "William Dussault")]
struct Options {
    #[clap(subcommand)]
    action: Action,
}

impl Options {
    pub async fn execute(self) -> Result<()> {
        match self.action {
            Action::All { interactive } => strap::all(interactive).await,
            Action::Apply { tgt } => {
                for t in tgt {
                    strap::single(t).await?
                }
                Ok(())
            }
            Action::List => {
                for target in Target::all() {
                    println!("{target:?}");
                }
                Ok(())
            }
        }
    }
}

#[tokio::main]
async fn main() {
    if let Err(e) = Options::parse().execute().await {
        eprintln!("! Error: {}", e);
    }
}
