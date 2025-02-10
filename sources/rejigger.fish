function rejigger
    set dry_run 1
    if test $argv[1] = -f
        set -e argv[1]
        set dry_run 0
    else
        echo "-f not specified; doing dry run"
    end
    set album_name $argv[1]
    set -e argv[1]
    for f in $argv
        set parts (string split " - "$album_name" - " $f)
        if test (count $parts) -ne 2
            echo "no album name; skipping $f"
            continue
        end

        string match -rgq '(?<index>\d+) (?<title>.*)\.(?<ext>mp3|flac)' $parts[2]
        or begin
            echo "can't extract index/title/ext; skipping $f"
            continue
        end

        set d "$index. $parts[1] - $title.$ext"
        if test $dry_run -eq 1
            echo "would rename $f to $d"
        else
            echo "renaming $f to $d"
            mv $f $d
        end
    end
end
