# Bootstrap ar-install from the personal AR generic repository.

const AR_LOCATION = "northamerica-northeast1"
const AR_PROJECT  = "personal-workspace"
const AR_REPO     = "bin"
const AR_PACKAGE  = "ar-install"
const AR_PROXY     = "https://ar.execd.xyz"

def canonical_arch [arch: string] {
    match $arch {
        "amd64" | "x86_64" | "k8" | "darwin" | "darwin_x86_64" => "x86_64"
        "arm64" | "aarch64" | "darwin_arm64" => "aarch64"
        _ => $arch
    }
}

def canonical_os [os: string] {
    if $os == "macos" { "darwin" } else { $os }
}

# Match the package-OS-CPU-mode convention used by ar-install itself.
def select_file [files: list, os: string, arch: string] {
    let os = (canonical_os $os)
    let arch = (canonical_arch $arch)
    let archives = ($files | each {|file|
        let filename = ($file.name | split row "/" | last | url decode | split row ":" | last)
        {resource: $file.name, filename: $filename}
    } | where {|file| $file.filename =~ '\.(tar\.gz|tgz)$'})
    let matches = ($archives | where {|file|
        let platform = ($file.filename | parse --regex ('^' + $AR_PACKAGE + '-(?<os>[^-]+)-(?<arch>[^-]+)-[^-]+\.(tar\.gz|tgz)$'))
        if ($platform | is-empty) {
            false
        } else {
            (canonical_os $platform.0.os) == $os and (canonical_arch $platform.0.arch) == $arch
        }
    })
    if ($matches | length) == 1 {
        return $matches.0.resource
    }
    # Only accept an untagged legacy archive when it is the sole tarball.
    if ($matches | is-empty) and ($archives | length) == 1 {
        if $archives.0.filename in [$"($AR_PACKAGE).tar.gz" $"($AR_PACKAGE).tgz"] {
            return $archives.0.resource
        }
    }
    let reason = (if ($matches | is-empty) { "No" } else { "Multiple" })
    error make {msg: $"($reason) tarball matches ($os)/($arch) for ($AR_PACKAGE). Available: ($archives.filename | str join ', ')"}
}

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
    mut files = []
    mut page_token = ""
    loop {
        let page = (^curl --fail --silent --show-error --get
            --data-urlencode $"filter=owner=\"($version)\""
            --data-urlencode $"pageToken=($page_token)"
            $"($AR_PROXY)/v1/($repository)/files" | from json)
        $files = ($files | append ($page.files? | default []))
        $page_token = ($page.nextPageToken? | default "")
        if $page_token == "" { break }
    }
    let file = (select_file $files $nu.os-info.name $nu.os-info.arch)

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
        let files = (^gcloud artifacts files list --format json
            --project $AR_PROJECT --location $AR_LOCATION
            --repository $AR_REPO --package $AR_PACKAGE --version $ver
        | from json)
        let file = (select_file $files $nu.os-info.name $nu.os-info.arch)
        (^gcloud artifacts files download $file
            --project $AR_PROJECT --location $AR_LOCATION
            --repository $AR_REPO --destination $tmp
            --local-filename ($dl | path basename))
    }

    let file_type = (^file -b $dl | str lowercase)
    if ($file_type | str contains "tar") or ($file_type | str contains "gzip") or ($file_type | str contains "xz") or ($file_type | str contains "bzip2") {
        ^tar -xf $dl -C $tmp; rm $dl
    } else if ($file_type | str contains "zip") {
        ^unzip -o -d $tmp $dl out+err> /dev/null; rm $dl
    }

    mkdir $install_dir
    for exe in (^find $tmp -type f -perm -111 | lines | where {|f| $f != ""}) {
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
