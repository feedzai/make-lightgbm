# make-lightgbm

This repo serves to build all the needed LightGBM artifacts to create a Java library, including a copy of OpenMP's .so, from a *"replica"* of LightGBM's CI build environment that does not require Microsoft credentials.

# Requirements

- bash & sed
- docker
- git

# How to use

To generate the `build/` folder with all necessary artifacts just run:

```bash
bash make.sh [lightgbm_version] [package_version] # where lightgbm_version is any of (commit_id, tag, branch)
```
If no `lightgbm_version` is specified, `master` is checked out.

If no `package_version` is specified:
 - If `lightgbm_version` is a release (`vMAJOR.MINOR.PATCH`), `package_version=MAJOR.MINOR.PATCH`.
 Otherwise, `package_version=0.0.0`.
 
Finally, in the output `pom.xml`, the package version is the one specified in `package_version`, except if it is `0.0.0`. In that case the build version becomes `package_version-lightgbm_version`.

## Output artifacts

This is the output:
```bash
build
├── __commit_id__
├── install_jar_locally.sh
├── libgomp.so.1.0.0
├── lib_lightgbm.so
├── lib_lightgbm_swig.so
├── lightgbmlib.jar
├── pom.xml
├── __timestamp__
└── __version__
```

Files with "__" are just single-line files containing meta-data for traceability so you don't lose track of build conditions.

You can now copy this folder into your project and either run `bash install_jar_locally.sh` or use maven's install plugin.






