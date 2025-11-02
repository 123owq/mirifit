allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Git 충돌 마커(<<<<<, =====, >>>>>)를 삭제하고
// 기능상 동일한 두 버전 중 하나만 남겼습니다.
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}