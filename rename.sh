#!/bin/bash

NEW_ROOT=$1
OLD_ROOT="HouseNewsWire"

if [ -z $NEW_ROOT ]; then
    echo "Usage: $0 NewName"
    echo ""
    echo "This program will rename HouseNewsWire to [NewName]"
    echo "HouseNewsWire::DB -> NewName::DB"
    echo "HouseNewsWire::Web -> NewName::Web"
    echo ""
    echo "New files will be created and updated with the new name."
    echo ""
    exit -1
fi

function rename_web {
    NEW_LIB_NAME=$1;
    OLD_LIB_NAME="HouseNewsWire::Web";

    NEW_LIB_PATH=$( echo $NEW_LIB_NAME | perl -pe's/::/\//g' );
    OLD_LIB_PATH=$( echo $OLD_LIB_NAME | perl -pe's/::/\//g' );

    echo "[Web] Will rename $OLD_LIB_NAME ($OLD_LIB_PATH) to $NEW_LIB_NAME";

    read -p "Continue? (^C to exit)"

    for FILE_PATH in `find lib -type f` ; do
        TARGET=$(echo $FILE_PATH | perl -pe "s|\Q$OLD_LIB_PATH\E|$NEW_LIB_PATH|" );
        TARGET_DIR=$(dirname $TARGET);
        echo "[Web] Rewrite $FILE_PATH -> $TARGET";
        mkdir -p $TARGET_DIR
        perl -pe "s/$OLD_LIB_NAME/$NEW_LIB_NAME/g, s/${OLD_ROOT}::DB/${NEW_ROOT}::DB/g" $FILE_PATH > $TARGET
    done
        
    echo "[Web] Rewrite app.psgi -> app.psgi";
    perl -pe "s/$OLD_LIB_NAME/$NEW_LIB_NAME/g" app.psgi > app.psgi.new
    mv app.psgi.new app.psgi

    echo "[Web] Remove old library files."
    rm -rf lib/$OLD_ROOT
}

function rename_database {
    NEW_LIB_NAME=$1;
    OLD_LIB_NAME="HouseNewsWire::DB";

    NEW_LIB_PATH=$( echo $NEW_LIB_NAME | perl -pe's/::/\//g' );
    OLD_LIB_PATH=$( echo $OLD_LIB_NAME | perl -pe's/::/\//g' );

    echo "[Database] Will rename $OLD_LIB_NAME ($OLD_LIB_PATH) to $NEW_LIB_NAME";

    read -p "Continue? (^C to exit)"

    echo "[Database] Dumping new lib...."
    ./bin/create-classes $NEW_LIB_NAME;

    echo "[Database] Copying ResultSets..."
    echo "[Database] Creating $NEW_LIB_PATH"
    mkdir lib/$NEW_LIB_PATH/ResultSet/
    for RS in `ls lib/$OLD_LIB_PATH/ResultSet/`; do
        echo "[Database] Rewriting $OLD_LIB_PATH/$RS ->  $NEW_LIB_PATH/$RS"
        perl -pe"s/$OLD_LIB_NAME/$NEW_LIB_NAME/g" lib/$OLD_LIB_PATH/ResultSet/$RS > lib/$NEW_LIB_PATH/ResultSet/$RS
    done

    echo "[Database] Appending extra Result code..."
    for RS in `ls lib/$OLD_LIB_PATH/Result/`; do
        echo "[Database] Rebuilding $OLD_LIB_PATH/$RS ->  $NEW_LIB_PATH/$RS"

        # We'regoing to remove the last three lines of each new file, figure out
        # how many lines until then.
        LINES=$(wc -l lib/$NEW_LIB_PATH/Result/$RS | awk '{print $1-3}')

        # Copy out that many lines into a temp file.
        head -n $LINES lib/$NEW_LIB_PATH/Result/$RS > lib/$NEW_LIB_PATH/Result/$RS.new

        # Append the old custom-code to the new temp file.
        perl -ne'print $_ if $IS_APPEND; $IS_APPEND += 1 if $_ =~ m|DO NOT MODIFY THIS OR ANYTHING ABOVE|;' \
            lib/$OLD_LIB_PATH/Result/$RS >> lib/$NEW_LIB_PATH/Result/$RS.new

        # Replace real file with the one we built.
        mv lib/$NEW_LIB_PATH/Result/$RS.new lib/$NEW_LIB_PATH/Result/$RS
    done
    echo "[Database] Rewrite dist.ini -> dist.ini";
    perl -pe "s/HouseNewsWire/$NEW_ROOT/g" dist.ini > dist.ini.new
    mv dist.ini.new dist.ini

    echo "[Database] Remove old library files."
    rm -rf lib/$OLD_ROOT
}


cd Web/
rename_web "${NEW_ROOT}::Web"
cd ..


cd Database/
rename_database "${NEW_ROOT}::DB"
cd ..
