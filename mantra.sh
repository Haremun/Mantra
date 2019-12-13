#!/bin/bash
# Author: Kamil Bieganski

NAME=${1:-"my-app"}
GROUP=${2:-"com.bieganski"}
GROUP_PATH="${GROUP//.//}"
VERSION=${3:-"0.1"}
FOLDER_STRUCTURE="$NAME"/src/{main,test}/java/"$GROUP_PATH"/"$NAME" 

echo "Generating project $NAME with groupId $GROUP, version $VERSION.."
echo "Creating folder structure.."

mkdir -p "$NAME"/src/{main,test}/java/"$GROUP_PATH"/ 
touch "$NAME"/src/main/java/"$GROUP_PATH"/App.java
mkdir "$NAME"/src/{main,test}/resources
touch "$NAME"/src/test/java/"$GROUP_PATH"/AppTest.java

echo "Generating pom.xml.."

curl -L -s https://raw.githubusercontent.com/Haremun/Mantra/master/pom.xml > "$NAME"/pom.xml
#sed -i s/com.mycompany.app/"$GROUP"/g "$NAME"/pom.xml
sed -i s/#ARTI/\L"$NAME"/g "$NAME"/pom.xml
sed -i s/1.0-SNAPSHOT/"$VERSION"/g "$NAME"/pom.xml
sed -i s/#GROUP/"$GROUP"/g "$NAME"/pom.xml

echo "Generating readme.md.."

cat << EOF > "$NAME"/readme.adoc
Title: $NAME
Author: Kamil Bieganski
Version: $VERSION

To run project you have to use:
- bash or other compatible unix shell
- jdk version $(java --version | head -n 1)
- maven version $(mvn -v | head -n 1 | grep -o [0-9]\.[0-9]\.[0-9])

To build project simply run "mvn package" command, to make it work run "java -cp target/$NAME-$VERSION.jar $GROUP.$NAME"
EOF

echo "Generating .gitignore.."

curl -L -s http://gitignore.io/api/java,linux,maven,intellij > "$NAME"/.gitignore
echo "*.class" >> "$NAME"/.gitignore
echo "*.swp" >> "$NAME"/.gitignore
echo ".idea" >> "$NAME"/.gitignore

echo "Project generated succesfully."
echo "Initializing git repository and creating first commit.."

cd "$NAME"/
git init
git add .
git commit -m "initialize commit"

echo "Opening project with Intellij Idea.."

intellij-idea-community pom.xml . &
