# Bootstrap ar-install from the personal AR generic repository.

const AR_LOCATION = "northamerica-northeast1"
const AR_PROJECT  = "personal-workspace"
const AR_REPO     = "bin"
const AR_PACKAGE  = "ar-install"
const AR_PROXY     = "https://ar.execd.xyz"

def proxy_available [] {
    let result = (^curl --fail --silent --show-error --output /dev/null
        --connect-timeout 1 --max-time 3 $"($AR_PROXY)/healthz" | complete)
    $result.exit_code == 0
}

def proxy_download [destination: path] {
    let repository = $"projects/($AR_PROJECT)/locations/($AR_LOCATION)/repositories/($AR_REPO)"
    let package = $"($repository)/packages/($AR_PACKAGE)"
    let version = (^curl --fail --silent --show-error --get
        --data-urlencode "orderBy=createTime desc" --data-urlencode "pageSize=1"
        $"($AR_PROXY)/v1/($package)/versions"
    | from json | get versions | first | get name)
    let file = (^curl --fail --silent --show-error --get
        --data-urlencode $"filter=owner=\"($version)\""
        $"($AR_PROXY)/v1/($repository)/files"
    | from json | get files
    | where {|f| $f.name | str ends-with ".tar.gz"}
    | first | get name)

    print $"Downloading ($AR_PACKAGE) (($version | split row "/" | last)) via Artifact Registry proxy..."
    ^curl --fail --location --silent --show-error --output $destination $"($AR_PROXY)/v1/($file):download?alt=media"
}

export def bootstrap [] {
    let install_dir = ($env.HOME | path join "bin")
    let tmp = (^mktemp -d | str trim)
    let dl = ($tmp | path join $"($AR_PACKAGE).tar.gz")

    if (proxy_available) {
        proxy_download $dl
    } else {
        let ver = (^gcloud artifacts versions list --format json
            --project $AR_PROJECT --location $AR_LOCATION
            --repository $AR_REPO --package $AR_PACKAGE
        | from json | sort-by createTime --reverse | first | get name | split row "/" | last)

        print $"Artifact Registry proxy unavailable; downloading ($AR_PACKAGE) ($ver) with gcloud..."
        (^gcloud artifacts generic download
            --project $AR_PROJECT --location $AR_LOCATION
            --repository $AR_REPO --package $AR_PACKAGE --version $ver
            --destination $tmp)
    }

    let file_type = (^file -b $dl | str lowercase)
    if ($file_type | str contains "tar") or ($file_type | str contains "gzip") or ($file_type | str contains "xz") or ($file_type | str contains "bzip2") {
        ^tar -xf $dl -C $tmp; rm $dl
    } else if ($file_type | str contains "zip") {
        ^unzip -o -d $tmp $dl out+err> /dev/null; rm $dl
    }

    mkdir $install_dir
    for exe in (^find $tmp -type f -executable | lines | where {|f| $f != ""}) {
        let name = ($exe | path basename)
        ^mv -f $exe ($install_dir | path join $name)
        print $"Installed ($name) -> ($install_dir)/($name)"
    }
}

export def install [name:string, version?:string] {
  # bootstrap the ar-install tool if it is not already installed
  if (^which ar-install | is-empty ) {
    print "ar-install not found, bootstrapping..."
    bootstrap
  }
  if $version == null {
    ar-install $name
  } else {
    ar-install $name --version $version
  }
}
