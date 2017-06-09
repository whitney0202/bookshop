#!/usr/bin/env sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

proj_name=$(cat project_name)


files=($@)
echo ${files[@]}
suffix=""
compile_java="1"
if [ "${files[0]}" == "web" ]; then
    suffix=${files[1]}
    compile_java="0"
    files="web/"${files[@]:1}
else
    files="web/*";
    /bin/rm -rf release/*
fi

[ -d release ] || mkdir release
[ -d release/"$proj_name" ] || mkdir release/"$proj_name"
[ -d release/"$proj_name"/WEB-INF ] || mkdir release/"$proj_name"/WEB-INF
[ -d release/"$proj_name"/WEB-INF/classes ] || mkdir release/"$proj_name"/WEB-INF/classes

echo cp -rf ${files} release/"$proj_name"/"$suffix"
cp -rf ${files} release/"$proj_name"/"$suffix"

if [ $? != 0 ]; then
    echo cp false;
    cp -rf web/* release/"$proj_name"/
fi

files=($@)
if [ "$compile_java" == "1" ]; then
    tomcat_home=$(cat tomcat_home)
    if [ ! "${files[0]}" == "java" ]; then
        echo compile_java ALL
        find src -name "*.java" > sources.txt
        javac -cp "$tomcat_home""lib/servlet-api.jar" -cp "$tomcat_home""lib/jsp-api.jar" -cp "web/WEB-INF/lib/*"\
        -d release/"$proj_name"/WEB-INF/classes \
        -encoding utf-8 @sources.txt
    else
        echo compile_java ${files[@]:1}
        javac -cp "$tomcat_home""lib/servlet-api.jar" -cp "$tomcat_home""lib/jsp-api.jar" -cp "web/WEB-INF/lib/*"\
        -d release/"$proj_name"/WEB-INF/classes \
        -encoding utf-8 ${files[@]:1}
    fi
fi