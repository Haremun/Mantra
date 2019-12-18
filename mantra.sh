#!/bin/bash
#Author: Kamil Bieganski

NAME=${1:-"my-app"}
GROUP=${2:-"com.bieganski"}
GROUP_PATH="${GROUP//.//}"
VERSION=${3:-"0.1"}
ARTIFACT=$(echo "$NAME" | sed 's/\([a-z0-9]\)\([A-Z]\)/\L\1_\L\2/g; s/\s/_/g' | tr '[:upper:]' '[:lower:]')
#FOLDER_STRUCTURE="$NAME"/src/{main,test}/java/"$GROUP_PATH"/"$NAME" 

echo "Generating project $NAME with groupId $GROUP, version $VERSION.."
echo "Creating folder structure.."

mkdir -p "$NAME"/src/{main,test}/{java,resources}/"$GROUP_PATH"/"$ARTIFACT" 
touch "$NAME"/src/main/java/"$GROUP_PATH"/"$ARTIFACT"/App.java
#mkdir "$NAME"/src/{main,test}/resources
touch "$NAME"/src/test/java/"$GROUP_PATH"/"$ARTIFACT"/AppTest.java

echo "Generating pom.xml.."

curl -L -s https://raw.githubusercontent.com/Haremun/Mantra/master/pom.xml > "$NAME"/pom.xml
sed -i s/#NAME/"$NAME"/g "$NAME"/pom.xml
sed -i s/1.0-SNAPSHOT/"$VERSION"/g "$NAME"/pom.xml
sed -i s/#GROUP/"$GROUP"/g "$NAME"/pom.xml
sed -i s/#ARTI/"$ARTIFACT"/g "$NAME"/pom.xml

echo "Generating readme.adoc.."

cat << EOF > "$NAME"/readme.adoc
Title: $NAME
Author: Kamil Bieganski
Version: $VERSION

To run project you have to use:
- bash or other compatible unix shell
- jdk version $(java --version | head -n 1)
- maven version $(mvn -v | head -n 1 | grep -o '[0-9]\\.[0-9]\\.[0-9]')

To build project simply run "mvn package" command, to make it work run "java -cp target/$NAME-$VERSION.jar $GROUP.$NAME"
EOF
cat << EOF > "$NAME"/src/main/java/"$GROUP_PATH"/"$ARTIFACT"/App.java
package $GROUP.$ARTIFACT;

public class App{
	public static void main(String[] args){
		System.out.println("Hello world!");
	}
}
EOF
cat << EOF > "$NAME"/src/test/java/"$GROUP_PATH"/"$ARTIFACT"/AppTest.java
package $GROUP.$ARTIFACT;

import org.testng.annotations.Test;

@Test
public class AppTest{

}
EOF


echo "Generating .gitignore.."

curl -L -s http://gitignore.io/api/java,linux,maven,intellij > "$NAME"/.gitignore
echo "*.swp" >> "$NAME"/.gitignore
echo ".idea" >> "$NAME"/.gitignore
echo "*.iml" >> "$NAME"/.gitignore
echo "stale_outputs_checked" >> "$NAME"/.gitignore

echo "Project generated succesfully."
echo "Initializing git repository and creating first commit.."

cd "$NAME" || exit
git init
git add .
git commit -m "initialize commit"

echo "Opening project with Intellij Idea.."

intellij-idea-community pom.xml . &
