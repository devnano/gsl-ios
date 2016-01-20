#!/bin/sh

LOCAL_OUTDIR="./outdir"
IOS_DEPLOY_TGT="7.0"

setenv_all()
{
    export CXX=$TCROOT/clang++
    export CC=$TCROOT/clang
	export LD=$TCROOT/ld
	export AR=$TCROOT/ar
	export AS=$TCROOT/as
	export NM=$TCROOT/nm
	export RANLIB=$TCROOT/ranlib
	export LDFLAGS="-L$SDKROOT/usr/lib/"
    export CXXFLAGS=$CFLAGS
    export CPPFLAGS=$CFLAGS
}

setenv_arm7s()
{
    unset SDKROOT TCROOT CFLAGS CC LD CXX AR AS NM RANLIB LDFLAGS CXXFLAGS CPPFLAGS

    export SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk
    export TCROOT=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin

	export CFLAGS="-arch armv7s -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT -I$SDKROOT/usr/include/"
	
	setenv_all
}

setenv_arm7()
{
    unset SDKROOT TCROOT CFLAGS CC LD CXX AR AS NM RANLIB LDFLAGS CXXFLAGS CPPFLAGS

    export SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk
    export TCROOT=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin

	export CFLAGS="-arch armv7 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT -I$SDKROOT/usr/include/"
	
	setenv_all
}

setenv_arm64()
{
    unset SDKROOT TCROOT CFLAGS CC LD CXX AR AS NM RANLIB LDFLAGS CXXFLAGS CPPFLAGS

    export SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk
    export TCROOT=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin

    export CFLAGS="-arch arm64 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT -I$SDKROOT/usr/include/"

    setenv_all
}

setenv_i386()
{
	unset SDKROOT TCROOT CFLAGS CC LD CXX AR AS NM RANLIB LDFLAGS CXXFLAGS CPPFLAGS

    export SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk
    export TCROOT=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin

	export CFLAGS="-arch i386 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT"
	
	setenv_all
}

setenv_x86_64()
{
	unset SDKROOT TCROOT CFLAGS CC LD CXX AR AS NM RANLIB LDFLAGS CXXFLAGS CPPFLAGS

    export SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk
    export TCROOT=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin

	export CFLAGS="-arch x86_64 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT"
	
	setenv_all
}


create_outdir_lipo()
{
	for lib_i386 in `find $LOCAL_OUTDIR/i386 -name "lib*.a"`; do
        lib_arm7s=`echo $lib_i386 | sed "s/i386/arm7s/g"`
        lib_arm7=`echo $lib_i386 | sed "s/i386/arm7/g"`
        lib_arm64=`echo $lib_i386 | sed "s/i386/arm64/g"`
        lib_x86_64=`echo $lib_i386 | sed "s/i386/x86_64/g"`
		lib=`echo $lib_i386 | sed "s/i386//g"`
		xcrun -sdk iphoneos lipo -arch x86_64 $lib_x86_64 -arch arm64 $lib_arm64 -arch armv7s $lib_arm7s -arch armv7 $lib_arm7 -arch i386 $lib_i386 -create -output $lib

	done
}

merge_libfiles()
{
	DIR=$1
	LIBNAME=$2
	
	cd $DIR
	for i in `find . -name "lib*.a"`; do
		$AR -x $i
	done
	$AR -r $LIBNAME *.o
	rm -rf *.o __*
	cd -
}

rm -rf $LOCAL_OUTDIR
mkdir -p $LOCAL_OUTDIR/i386 $LOCAL_OUTDIR/arm7 $LOCAL_OUTDIR/arm7s $LOCAL_OUTDIR/arm64 $LOCAL_OUTDIR/x86_64

make clean 2> /dev/null
make distclean 2> /dev/null
setenv_x86_64
./configure --enable-shared=no -enable-static
make
for i in `find . -path $LOCAL_OUTDIR -prune -o -name "lib*.a" -print | grep -v arm`; do cp -rvf $i $LOCAL_OUTDIR/x86_64; done
merge_libfiles $LOCAL_OUTDIR/x86_64 libgsl_all.a

make clean 2> /dev/null
make distclean 2> /dev/null
setenv_arm7
./configure --host=arm-apple-darwin7s --enable-shared=no -enable-static
make
for i in `find . -path $LOCAL_OUTDIR -prune -o -name "lib*.a" -print | grep -v arm`; do cp -rvf $i $LOCAL_OUTDIR/arm7; done
merge_libfiles $LOCAL_OUTDIR/arm7 libgsl_all.a


make clean 2> /dev/null
make distclean 2> /dev/null
setenv_arm7s
./configure --host=arm-apple-darwin7s --enable-shared=no -enable-static
make
for i in `find . -path $LOCAL_OUTDIR -prune -o -name "lib*.a" -print | grep -v arm`; do cp -rvf $i $LOCAL_OUTDIR/arm7s; done
merge_libfiles $LOCAL_OUTDIR/arm7s libgsl_all.a

make clean 2> /dev/null
make distclean 2> /dev/null
setenv_arm64
./configure --host=arm-apple-darwin64 --enable-shared=no -enable-static
make
for i in `find . -path $LOCAL_OUTDIR -prune -o -name "lib*.a" -print | grep -v arm`; do cp -rvf $i $LOCAL_OUTDIR/arm64; done
merge_libfiles $LOCAL_OUTDIR/arm64 libgsl_all.a

make clean 2> /dev/null
make distclean 2> /dev/null
setenv_i386
./configure --enable-shared=no -enable-static
make
for i in `find . -path $LOCAL_OUTDIR -prune -o -name "lib*.a" -print | grep -v arm`; do cp -rvf $i $LOCAL_OUTDIR/i386; done
merge_libfiles $LOCAL_OUTDIR/i386 libgsl_all.a

create_outdir_lipo

echo "Finished!"
