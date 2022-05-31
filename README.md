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

### Building from another LightGBM repository

By defining the environment variable `LIGHTGBM_REPO_URL` which by default points to [LightGBM](https://github.com/microsoft/LightGBM), to another `http(s)` git LightGBM repo URL, you can build your own custom version of LightGBM. This can be useful to try building our own patched/custom versions of LightGBM. Ensure you use the _http(s)_ protocol instead of _git_.

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



# Extra: Debugging for developers (local patches)

This explains how to build local patches for LightGBM and have quicker iterations during LightGBM C++ 
development/debugging. This can be useful to prototype changes in the C++ codebase or debug.

For instance, to perform debugging, one must build LightGBM using the compiler toolchain available 
on the target machine running the debugger to have symbol compatibility. Using the standard "cross-platform"
build provided in this repo would lead to symbol compatibility issues, as it uses on purpose a very
old compiler toolchain to achieve practically a "cross-platform"/universal build that can run on any modern Linux distro.

Patching hence is done in a two-stage process:
1. Run at least once the base `make.sh` to have the base build.
2. Patch the base build by calling `make.sh` in patch mode as explained below.

### Preparing the patch build environment

Clone the relevant LightGBM repo/fork to your computer and run CMake with the desired flags:
```bash
cd my_lgbm_repo
mkdir build
cd build
cmake .. -DUSE_DEBUG=ON -DUSE_SWIG=ON
```

### Running `make.sh` in patch mode

After the CMake setup is complete, simply export `$BUILD_LGBM_PATCH_FROM` to that _build_ folder before 
running `make.sh` as many times as you want.

This will compile LightGBM from source with your settings and patch the base LightGBM build in the provider.

