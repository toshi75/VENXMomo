#!/usr/bin/env bash
#printf '\033[?7l' # disable word wrap
#set -ex
rm -fr /tmp/scr &>/dev/null
readonly DIR="$(cd "$(dirname "$0")";pwd)"
cd "${DIR}"
if [[ -d "${DIR}"/WD ]] ;then
   #mv -b "${DIR}"/WD{,_OLD}
    rm -fr "${DIR}"/WD
fi

readonly WD="${DIR}/WD"
readonly DL="${DIR}/DLsources"
[[ ! -d "${DIR}"/scripts ]] && exit 99
readonly SCR="${DIR}/scripts"
mkdir -p "${DL}/LICENSE"
mkdir -p "${WD}"
mkdir -p "/tmp/scr"

cd "${DL}"
LIST=(
    'be5invis/Iosevka'
    'ryanoasis/nerd-fonts'
    'microsoft/cascadia-code'
    'yuru7/udev-gothic'
    'chrissimpkins/fontname.py'
)
for i in "${LIST[@]}" ;do
    # Ver.check
    VER="$(
        wget -O - https://github.com/"$i" |
        sort -u |
        grep 'releases/tag' |
        sed -e 's|^.*\/v||g' -e 's|".*$||g'
    )"
    # 最新ソースを持っているならDLしない
    case "$i" in
        'be5invis/Iosevka')
              FILE="v${VER}.zip"
            SAVEAS="Iosevka-v${VER}.zip" ;;
        'microsoft/cascadia-code')
              FILE="CascadiaCode-${VER}.zip"
            SAVEAS="CascadiaCode-v${VER}.zip"  ;;
        'ryanoasis/nerd-fonts')
              FILE="FontPatcher.zip"
            SAVEAS="FontPatcher-v${VER}.zip"   ;;
        'yuru7/udev-gothic')
              FILE="v${VER}.zip"
            SAVEAS="udev-gothic-v${VER}.zip"
           UDEVVER="${VER}"                    ;;
        'chrissimpkins/fontname.py')
              FILE="v${VER}.zip"
            SAVEAS="fontname_py-v${VER}.zip"   ;;
    esac
    CKFONTFORGE=0
    if [[ ! -f "${DL}/${SAVEAS}" ]] ;then
        if   [[ "$i" == 'yuru7/udev-gothic' ]] ||
             [[ "$i" == 'be5invis/Iosevka'  ]] ||
             [[ "$i" == 'chrissimpkins/fontname.py' ]] ;then
            wget -O "${SAVEAS}" \
                "https://github.com/${i}/archive/refs/tags/v${VER}.zip"
            CKFONTFORGE=1
        elif [[ "$i" == 'microsoft/cascadia-code' ]] ;then
            wget -O "${DL}/${SAVEAS}" \
                "https://github.com/${i}/releases/download/v${VER}/${FILE}"
            mkdir -p "${DL}"/CCC
            cd "${DL}"/CCC
            wget "https://github.com/${i}/archive/refs/tags/v${VER}.zip"
            unzip -jo v*.zip -d ./
            cd "${DL}"
            find "${DL}"/CCC -type f -name 'OFL-FAQ.txt' -or \
                                     -name 'LICENSE' |
            while read -r i ;do
                mv -f "$i" -t "${DL}/LICENSE"
            done
            mv  -f "${DL}/LICENSE/LICENSE" \
                -T "${DL}/LICENSE/LICENSE_CascadiaCode.txt"
            rm -fr "${DL}"/CCC
        elif [[ "$i" == 'ryanoasis/nerd-fonts'    ]] ;then
            wget -O "${SAVEAS}" \
                "https://github.com/${i}/releases/download/v${VER}/${FILE}"
        fi
    fi
done
cd "${DL}"
unzip Iosevka*.zip -d "${WD}"
mv "${WD}"/Iosevka* -T "${WD}"/Iosevka
cp -f "${WD}"/Iosevka/LICENSE.md \
   -T "${DL}/LICENSE/LICENSE_Iosevka.md"
unzip udev*.zip -d "${WD}"

[[ "${CKFONTFORGE}" -eq 1 ]] &&
mv "${WD}"/udev-gothic-${UDEVVER} -T "${WD}"/UDEV &>/dev/null

cp -f "${WD}"/UDEV/LICENSE \
   -T "${DL}"/LICENSE/LICENSE_UDEVGothic.txt
cp -f "${WD}"/UDEV/source/LICENSE_* \
   -t "${DL}"/LICENSE
unzip -o FontPa*.zip -d /tmp/scr
{   cd "${DL}"
    mkdir -p "${WD}"/TTT
    unzip -jo fontname*.zip -d "${WD}"/TTT
    mv "${WD}"/TTT/fontname.py "${WD}"
    rm -fr "${WD}"/TTT
}
{   cd "${DL}"
    mkdir -p "${WD}"/Cascadia
    unzip "${DL}"/Cascadia*.zip -d "${WD}"/Cascadia
    mv -t "${WD}"/Cascadia \
        "${WD}"/Cascadia/ttf/static/Cascadia{Code,Mono}-{Bold{,Italic},Italic,Regular}.ttf
    rm -fr "${WD}"/Cascadia/{otf,ttf,woff2}
}
for i in "${DIR}"/scripts/*.pe ;do
    sed -e "s|\/usr\/bin\/fontforge|$(which fontforge)|" \
        -i "$i"
    chmod +x "$i"
    cp -t /tmp/scr "$i"
done
if [[ "$(which fontforge)" != "/usr/local/bin" ]] &&
   [[ "${CKFONTFORGE}"    -eq 1                ]] ;then
    sed -e "s|\/usr\/local\/bin\/fontforge|$(which fontforge) --quiet |" \
        -i "${WD}/UDEV/generator.sh"
    cd "${WD}"
    zip -r "udev-gothic-v${UDEVVER}.zip" "UDEV"
    mv -f udev-gothic-v${UDEVVER}.zip -t "${DL}"
fi

cp -f "${DIR}"/scripts/LICENSE_VENXMomo \
      "${DIR}"/scripts/*.pdf \
   -t "${DL}"/LICENSE

if ( type dolphin &>/dev/null ) ;then
    echo '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" version="1"><rect width="28" height="18" x="2" y="11" rx="1.4" ry="1.4" style="opacity:.2"/><path d="M2 22.6c0 .776.624 1.4 1.4 1.4h25.2c.776 0 1.4-.624 1.4-1.4V7.4c0-.776-.624-1.4-1.4-1.4H16c-2.1 0-2.8-3-4.9-3H3.4C2.624 3 2 3.624 2 4.4" style="fill:#ff9000"/><rect width="28" height="18" x="2" y="9" rx="1.4" ry="1.4" style="opacity:.2"/><rect width="24" height="11" x="4" y="8" rx="1.4" ry="1.4" style="fill:#e4e4e4"/><rect width="28" height="18" x="2" y="10" rx="1.4" ry="1.4" style="fill:#0f4c81"/><path d="M3.4 3C2.625 3 2 3.625 2 4.4v1C2 4.625 2.625 4 3.4 4h7.7c2.1 0 2.8 3 4.9 3h12.6c.775 0 1.4.625 1.4 1.4v-1c0-.775-.625-1.4-1.4-1.4H16c-2.1 0-2.8-3-4.9-3Z" style="opacity:.1;fill:#fff"/><path d="M14.5 12c-1 0-1 1-1 1h-3s-1 0-1 1v1h13v-1c0-1-1-1-1-1h-3s0-1-1-1zm-4 4v9c0 .52.48 1 1 1h9c.52 0 1-.48 1-1v-9z" class="ColorScheme-Text" style="color:#ff0;fill:#f90"/></svg>' \
        >"${WD}"/.trash.svg
    cat << ___1 >"${WD}"/.directory
[Desktop Entry]
Icon=./.trash.svg

[Dolphin]
SortHiddenLast=true
Timestamp=$(date '+%Y,%m,%d,%H,%M,%S').$((RANDOM%10))$((RANDOM%10))$((RANDOM%10))
Version=4
VisibleRoles=Icons_text,Icons_size
___1
    echo '<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" version="1"><rect width="56" height="36" x="4" y="22" rx="2.8" ry="2.8" style="opacity:.2"/><path d="M4 46.2C4 47.751 5.249 49 6.8 49h50.4c1.551 0 2.8-1.249 2.8-2.8V15.8c0-1.551-1.249-2.8-2.8-2.8H32c-4.2 0-5.6-6-9.8-6H6.8A2.794 2.794 0 0 0 4 9.8" style="fill:#ff9000"/><rect width="56" height="36" x="4" y="20" rx="2.8" ry="2.8" style="opacity:.2"/><rect width="48" height="22" x="8" y="16" rx="2.8" ry="2.8" style="fill:#e4e4e4"/><rect width="56" height="36" x="4" y="21" rx="2.8" ry="2.8" style="fill:#0f4c81"/><path d="M6.8 7C5.25 7 4 8.25 4 9.8v1.001A2.795 2.795 0 0 1 6.8 8h15.4c4.2 0 5.601 6 9.801 6H57.2a2.796 2.796 0 0 1 2.8 2.801v-1A2.796 2.796 0 0 0 57.199 13H32c-4.2 0-5.601-6-9.801-6Z" style="opacity:.1;fill:#fff"/><path d="M30 29v8h-4l6 8 6-8h-4v-8Zm-6 16v4h16v-4Z" style="fill:#ff9000"/></svg>' \
        >"${DIR}"/DLsources/.dl.svg
    cat << ___2 >"${DIR}"/DLsources/.directory
[Desktop Entry]
Icon=./.dl.svg

[Dolphin]
SortHiddenLast=true
Timestamp=$(date '+%Y,%m,%d,%H,%M,%S').$((RANDOM%10))$((RANDOM%10))$((RANDOM%10))
Version=4
VisibleRoles=Icons_text,Icons_size
___2
    echo '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" version="1"><rect width="28" height="18" x="2" y="11" rx="1.4" ry="1.4" style="opacity:.2"/><path d="M2 22.6c0 .776.624 1.4 1.4 1.4h25.2c.776 0 1.4-.624 1.4-1.4V7.4c0-.776-.624-1.4-1.4-1.4H16c-2.1 0-2.8-3-4.9-3H3.4C2.624 3 2 3.624 2 4.4" style="fill:#ff9000"/><rect width="28" height="18" x="2" y="9" rx="1.4" ry="1.4" style="opacity:.2"/><rect width="24" height="11" x="4" y="8" rx="1.4" ry="1.4" style="fill:#e4e4e4"/><rect width="28" height="18" x="2" y="10" rx="1.4" ry="1.4" style="fill:#0f4c81"/><path d="M3.4 3C2.625 3 2 3.625 2 4.4v1C2 4.625 2.625 4 3.4 4h7.7c2.1 0 2.8 3 4.9 3h12.6c.775 0 1.4.625 1.4 1.4v-1c0-.775-.625-1.4-1.4-1.4H16c-2.1 0-2.8-3-4.9-3Z" style="opacity:.1;fill:#fff"/><path d="M10 13v12h12V13zm3 1h1v1h.5c.65 0 1.2.42 1.41 1H14v1h.5c.83 0 1.5.67 1.5 1.5s-.67 1.5-1.5 1.5H14v1h-1v-1h-.5c-.65 0-1.2-.42-1.41-1H13v-1h-.5c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5h.5zm-.5 2c-.28 0-.5.22-.5.5s.22.5.5.5h.5v-1zm1.5 2v1h.5c.28.01.5-.22.5-.5s-.22-.5-.5-.5zm3 2h4v1h-4z" style="fill:#ff9000"/></svg>' \
        >"${DIR}"/scripts/.src.svg
    cat << ___3 >"${DIR}"/scripts/.directory
[Desktop Entry]
Icon=./.src.svg

[Dolphin]
SortHiddenLast=true
if [[ "${MOD1}" -eq 1 ]]
Timestamp=$(date '+%Y,%m,%d,%H,%M,%S').$((RANDOM%10))$((RANDOM%10))$((RANDOM%10))
Version=4
VisibleRoles=Icons_text,Icons_size
___3
fi

if [[ -f "${SCR}/private-build-plans.toml"  ]] ;then
    readonly FONTNAME="$(
        cat "${SCR}"/private-build-plans.toml |
        grep ^'family' |
        sed -e 's|^.*=\s"||g' -e 's|"$||g'
    )"
else
    readonly FONTNAME="IosevkaCustom"
    cat << '####==toml==####' >"${SCR}"/private-build-plans.toml
[buildPlans.IosevkaCustom]
family = "IosevkaCustom"
spacing = "term"
serifs = "sans"
noCvSs = true
exportGlyphNames = false

  [buildPlans.IosevkaCustom.variants]
  inherits = "m@_@m"

[buildPlans.IosevkaCustom.weights.Regular]
shape = 400
menu = 400
css = 400

[buildPlans.IosevkaCustom.weights.Bold]
shape = 700
menu = 700
css = 700mp/0/rc2/scripts/1.build-iosevka.sh: Line 101)



[buildPlans.IosevkaCustom.widths.Normal]
shape = 600
menu = 5
css = "normal"

####==toml==####
    NUM=$((RANDOM%21))
    if [[ $NUM -eq 0 ]] ;then
        sed -e 's|^.*variants.*$||' \
            -e 's|^.*inherits.*$||' \
            -i "${SCR}"/private-build-plans.toml
    elif [[ $NUM -ge 1 ]] && [[ $NUM -le 9 ]] ;then
        sed -e "s|m@_@m|ss0${NUM}|" \
            -i "${WD}"/Iosevka/private-build-plans.toml
    else
        sed -e "s|m@_@m|ss${NUM}|" \
            -i "${WD}"/Iosevka/private-build-plans.toml
    fi

fi
cp -f "${SCR}/private-build-plans.toml" \
   -t "${WD}"/Iosevka

cd "${WD}/Iosevka"
npm install
npm run build -- ttf::${FONTNAME}

#set -ex
cd "${WD}"
mkdir -p "${WD}"/Iosevka-TTF
find "${WD}"/Iosevka/dist/*/TTF -type f -iname '*-*.ttf' |
grep  -e '-Bold.ttf'   -e '-BoldItalic.ttf' -e '-BoldOblique.ttf' \
      -e '-Italic.ttf' -e '-Oblique.ttf'    -e '-Regular.ttf' |
while read i ;do
    mv -t "${WD}"/Iosevka-TTF "$i"
done
rm -fr "${WD}"/Iosevka
mv "${WD}"/Iosevka-TTF "${WD}"/Iosevka
cd "${WD}"
FUNC_NERD(){
    fontforge --quiet \
          --script /tmp/scr/font-patcher \
          --complete --no-progressbars "$1"
    mkdir "$(dirname "$1")"/orig_fonts
    mv "$1" -t "$(dirname "$1")"/orig_fonts
    return 0
}
export -f FUNC_NERD
for i in "${WD}"/{Iosevka,Cascadia} ;do
    cd "${i}"
    ls -1AU *.ttf |
    xargs -r -d '\n' -P0 -I{} bash -c 'FUNC_NERD {}'
    for j in *.ttf ;do
        /tmp/scr/setEM.pe "$j"
    done
done

for i in "${WD}"/Iosevka/*.ttf ;do
    /tmp/scr/Iosevka.pe "$i"
done

for i in "${WD}"/Iosevka/*.ttf ;do
    mv "$i" "$(dirname "$i")/$(basename "$i" |sed -e 's|^.*-|IOS-|g')"
done

cp -r "${WD}"/Iosevka -T "${WD}"/Iosevka-OB

rm "${WD}"/Iosevka/*Oblique*.ttf
rm "${WD}"/Iosevka-OB/*c.ttf
mv "${WD}"/Iosevka-OB/IOS-BoldOblique.ttf \
    -T "${WD}"/Iosevka-OB/IOS-BoldItalic.ttf
mv "${WD}"/Iosevka-OB/IOS-Oblique.ttf \
    -T "${WD}"/Iosevka-OB/IOS-Italic.ttf

cp "${WD}"/Iosevka-OB/IOS-Bold.ttf       -T "${WD}"/Iosevka-OB/IOSNL-Bold.ttf
cp "${WD}"/Iosevka-OB/IOS-BoldItalic.ttf -T "${WD}"/Iosevka-OB/IOSNL-BoldItalic.ttf
cp "${WD}"/Iosevka-OB/IOS-Italic.ttf     -T "${WD}"/Iosevka-OB/IOSNL-Italic.ttf
cp "${WD}"/Iosevka-OB/IOS-Regular.ttf    -T "${WD}"/Iosevka-OB/IOSNL-Regular.ttf

for i in "${WD}"/Cascadia/*.ttf ;do
    mv "$i" "$(dirname "$i")/$(basename "$i" |
                               sed -e 's|^.*Cove.*-|CAS-|g' \
                                   -e 's|^.*Mono.*-|CASNL-|g')"
done
cp -r "${WD}"/Cascadia -T "${WD}"/Cascadia-NOMOD
for i in "${WD}"/Cascadia/*.ttf ;do
    /tmp/scr/Cascadia.pe "$i"
done
cp -r "${WD}"/Cascadia -T "${WD}"/Cascadia-OB
rm "${WD}"/Cascadia-OB/*c.ttf

for i in "${WD}"/Cascadia-OB/*{Bold,Regular}.ttf ;do
    cp "$i" -T "$(dirname "$i")/$(basename "$i" |
                                  sed -e 's|Bold|BoldItalic|g' \
                                      -e 's|Regular|Italic|g')"
done
for i in "${WD}"/Cascadia-OB/*.ttf ;do
    mv "$i" "$(dirname "$i")/$(basename "$i" |sed -e 's|-|OB-|g')"
done
for i in "${WD}"/Cascadia-OB/*c.ttf ;do
    /tmp/scr/OB.pe "$i"
done

cp "${WD}"/Cascadia-OB/*.ttf -t "${WD}"
#   cp "${WD}"/Iosevka-OB/*.ttf  -t "${WD}"

#    for i in {Bold,BoldItalic,Italic,Regular} ;do
#        /tmp/scr/cas2ios.pe "${WD}"/CASOB-${i}.ttf   "${WD}"/IOS-${i}.ttf
#        /tmp/scr/cas2ios.pe "${WD}"/CASNLOB-${i}.ttf "${WD}"/IOSNL-${i}.ttf
#    done
#    rm "${WD}"/CAS*.ttf
#    for i in {Bold,BoldItalic,Italic,Regular} ;do
#        mv "${WD}"/IOS-${i}.ttf   "${WD}"/JetBrainsMono-${i}.ttf
#        mv "${WD}"/IOSNL-${i}.ttf "${WD}"/JetBrainsMonoNL-${i}.ttf
#    done
for i in {Bold,BoldItalic,Italic,Regular} ;do
    mv "${WD}"/CASOB-${i}.ttf   "${WD}"/JetBrainsMono-${i}.ttf
    mv "${WD}"/CASNLOB-${i}.ttf "${WD}"/JetBrainsMonoNL-${i}.ttf
done
cp "${WD}"/JetBrainsMono-Bold.ttf    -T "${WD}"/zero-Bold.ttf
cp "${WD}"/JetBrainsMono-Regular.ttf -T "${WD}"/zero-Regular.ttf
/tmp/scr/zero.pe "${WD}"/zero-Bold.ttf
/tmp/scr/zero.pe "${WD}"/zero-Regular.ttf
rm "${WD}"/zero-*.ttf
cp "${WD}"/JetBrainsMono-Regular.ttf -T "${WD}"/JetBrainsMonoNerdFont-Regular.ttf

mv -f "${WD}"/JetBrains*.ttf "${WD}"/zero-*.sfd -t "${WD}"/UDEV/source

#CR11="[Iosevka]"
#CR12="Copyright 2015-2024, Renzhi Li (aka. Belleve Invis, belleve@typeof.net)."
CR21="[Cascadia Code]"
CR22="(c) 2021 Microsoft Corporation. All Rights Reserved."
CR31="[CJODMomo CVDXMomo IENEMomo VENXMomo]"
CR32="This font was created using the wisdom of everyone listed above and the childishly inelegant ShellScript I wrote."
CR33="Copyright 2024 toshi75 (Toshihiro Suzuki)"
sed -e "s|\[JetBrains Mono\]|${CR21}|g" \
    -e "s|^.*2020\sThe.*$|${CR22}\n|g" \
    -e "s|Otawara|Otawara\n\n${CR31}\n${CR32}\n${CR33}|g" \
    -i "${WD}"/UDEV/copyright.sh
sed -e 's|VERSION=.*$|VERSION="1.0.0"|g' \
    -e 's|UDEVGothic|CJODMomo|g' \
    -e 's|UDEV\sGothic|CJODMomo|g' \
    -e 's|UDEV\sGothic\s|CJODMomo|g' \
    -i "${WD}"/UDEV/make.sh
cd "${WD}"/UDEV
./make.sh
mv    "${WD}"/UDEV/build         -T "${DIR}"/CJODMomo
mv    "${WD}"/fontname.py        -t "${DIR}"/CJODMomo
cp -r "${DIR}"/DLsources/LICENSE -t "${DIR}"/CJODMomo

if ( type dolphin &>/dev/null ) ;then
echo '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" version="1"><rect width="28" height="18" x="2" y="11" rx="1.4" ry="1.4" style="opacity:.2"/><path d="M2 22.6c0 .776.624 1.4 1.4 1.4h25.2c.776 0 1.4-.624 1.4-1.4V7.4c0-.776-.624-1.4-1.4-1.4H16c-2.1 0-2.8-3-4.9-3H3.4C2.624 3 2 3.624 2 4.4" style="fill:#0f4c81"/><rect width="28" height="18" x="2" y="9" rx="1.4" ry="1.4" style="opacity:.2"/><rect width="24" height="11" x="4" y="8" rx="1.4" ry="1.4" style="fill:#e4e4e4"/><rect width="28" height="18" x="2" y="10" rx="1.4" ry="1.4" style="fill:#f90"/><path d="M3.4 3C2.625 3 2 3.625 2 4.4v1C2 4.625 2.625 4 3.4 4h7.7c2.1 0 2.8 3 4.9 3h12.6c.775 0 1.4.625 1.4 1.4v-1c0-.775-.625-1.4-1.4-1.4H16c-2.1 0-2.8-3-4.9-3Z" style="opacity:.1;fill:#fff"/><path d="M21.629 14c-2.819 0-4.479 3.243-5.498 5.955l-.016.045H13v1h2.771c-.685 1.967-.79 2.443-.79 2.443l-1.647 5.172c-.862 2.707-1.482 4.615-2.371 4.615-1.482 0-.89-1.238-2.074-1.238-.593 0-.889.385-.889.77C8 33.53 8.593 34 10.371 34c3.111 0 4.887-3.845 6.22-8.076l.747-2.387c.849-2.715.732-2.325.803-2.537H21v-1h-2.543l.074-.232c1.127-3.547 1.692-4.998 2.506-4.998 1.482 0 .89 1.23 2.074 1.23.593 0 .889-.277.889-.662 0-.77-.593-1.338-2.371-1.338" style="fill:#0f4c81" transform="matrix(.6 0 0 .6 4 4.6)"/><path d="M29.629 14c-2.819 0-4.479 3.243-5.498 5.955l-.016.045H21v1h2.771c-.685 1.967-.79 2.443-.79 2.443l-1.647 5.172c-.862 2.707-1.482 4.615-2.371 4.615-1.482 0-.89-1.238-2.074-1.238-.593 0-.889.385-.889.77 0 .769.593 1.238 2.371 1.238 3.111 0 4.887-3.845 6.22-8.076l.747-2.387c.849-2.715.732-2.325.803-2.537H29v-1h-2.543l.074-.232c1.127-3.547 1.692-4.998 2.506-4.998 1.482 0 .89 1.23 2.074 1.23.593 0 .889-.277.889-.662 0-.77-.593-1.338-2.371-1.338" style="fill:#0f4c81" transform="matrix(.6 0 0 .6 4 4.6)"/></svg>' \
    >"${DIR}"/CJODMomo/.font.svg
#echo '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" version="1"><rect width="28" height="18" x="2" y="11" rx="1.4" ry="1.4" style="opacity:.2"/><path d="M2 22.6c0 .776.624 1.4 1.4 1.4h25.2c.776 0 1.4-.624 1.4-1.4V7.4c0-.776-.624-1.4-1.4-1.4H16c-2.1 0-2.8-3-4.9-3H3.4C2.624 3 2 3.624 2 4.4" style="fill:#ff9000"/><rect width="28" height="18" x="2" y="9" rx="1.4" ry="1.4" style="opacity:.2"/><rect width="24" height="11" x="4" y="8" rx="1.4" ry="1.4" style="fill:#e4e4e4"/><rect width="28" height="18" x="2" y="10" rx="1.4" ry="1.4" style="fill:#0f4c81"/><path d="M3.4 3C2.625 3 2 3.625 2 4.4v1C2 4.625 2.625 4 3.4 4h7.7c2.1 0 2.8 3 4.9 3h12.6c.775 0 1.4.625 1.4 1.4v-1c0-.775-.625-1.4-1.4-1.4H16c-2.1 0-2.8-3-4.9-3Z" style="opacity:.1;fill:#fff"/><path d="M21.629 14c-2.819 0-4.479 3.243-5.498 5.955l-.016.045H13v1h2.771c-.685 1.967-.79 2.443-.79 2.443l-1.647 5.172c-.862 2.707-1.482 4.615-2.371 4.615-1.482 0-.89-1.238-2.074-1.238-.593 0-.889.385-.889.77C8 33.53 8.593 34 10.371 34c3.111 0 4.887-3.845 6.22-8.076l.747-2.387c.849-2.715.732-2.325.803-2.537H21v-1h-2.543l.074-.232c1.127-3.547 1.692-4.998 2.506-4.998 1.482 0 .89 1.23 2.074 1.23.593 0 .889-.277.889-.662 0-.77-.593-1.338-2.371-1.338" style="fill:#f90" transform="matrix(.6 0 0 .6 4 4.6)"/><path d="M29.629 14c-2.819 0-4.479 3.243-5.498 5.955l-.016.045H21v1h2.771c-.685 1.967-.79 2.443-.79 2.443l-1.647 5.172c-.862 2.707-1.482 4.615-2.371 4.615-1.482 0-.89-1.238-2.074-1.238-.593 0-.889.385-.889.77 0 .769.593 1.238 2.371 1.238 3.111 0 4.887-3.845 6.22-8.076l.747-2.387c.849-2.715.732-2.325.803-2.537H29v-1h-2.543l.074-.232c1.127-3.547 1.692-4.998 2.506-4.998 1.482 0 .89 1.23 2.074 1.23.593 0 .889-.277.889-.662 0-.77-.593-1.338-2.371-1.338" style="fill:#f90" transform="matrix(.6 0 0 .6 4 4.6)"/></svg>' \
#    >"${DIR}"/${i}/.font.svg
cat << ___4 >"${DIR}"/CJODMomo/.directory
[Desktop Entry]
Icon=./.font.svg

[Dolphin]
SortHiddenLast=true
Timestamp=$(date '+%Y,%m,%d,%H,%M,%S').$((RANDOM%10))$((RANDOM%10))$((RANDOM%10))
Version=4
VisibleRoles=Icons_text,Icons_size
___4
fi
set +ex
#printf '\033[?7h' # enable word wrap
exit 0


