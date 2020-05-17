# CMake ExternalProject buildfine for boost
project(boost)

# create a boost compiler config file using CMake's current compiler
# --------------------------------------------------------------------------------

# note: got some of the boost configuration options from here:
# https://github.com/pfultz2/cget/blob/master/cget/cmake/boost.cmake

# calculate bits of target
math(EXPR B2_ADDRESS_MODEL "${CMAKE_SIZEOF_VOID_P} * 8")

# the full set of toolsets is documented here:
# https://www.boost.org/doc/libs/1_64_0/doc/html/bbv2/reference.html

if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    set(B2_TOOLCHAIN_TYPE "msvc")
elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "AppleClang")
    set(B2_TOOLCHAIN_TYPE "clang-darwin")
elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    if(TARGET_WINDOWS)
        set(B2_TOOLCHAIN_TYPE "clang-win")
    elseif(TARGET_OSX)
        set(B2_TOOLCHAIN_TYPE "clang-darwin")
    else()
        set(B2_TOOLCHAIN_TYPE "clang-linux")
    endif()
elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Intel")
    if(TARGET_WINDOWS)
        set(B2_TOOLCHAIN_TYPE "intel-win")
    elseif(TARGET_OSX)
        set(B2_TOOLCHAIN_TYPE "intel-darwin")
    else()
        set(B2_TOOLCHAIN_TYPE "intel-linux")
    endif()
elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "PGI")
    set(B2_TOOLCHAIN_TYPE "pgi")
else()

	# We may encounter other compilers that are not GCC, but Boost.Build does not support them explicitly.
	# We'll have to hope they work enough like GCC to get by.
    set(B2_TOOLCHAIN_TYPE "gcc")
endif()

# collect search paths
if(CMAKE_CROSSCOMPILING)
    set(PREFIX_PATH ${CMAKE_FIND_ROOT_PATH} ${CMAKE_PREFIX_PATH})
else()
    set(PREFIX_PATH ${CMAKE_PREFIX_PATH})
endif()
set(SEARCH_PATHS)
foreach(PATHS ${PREFIX_PATH})
    set(SEARCH_PATHS "${SEARCH_PATHS}
<include>${CMAKE_PREFIX_PATH}/include
<library-path>${CMAKE_PREFIX_PATH}/lib")
endforeach()

set(B2_TOOLCHAIN_VERSION ambercmake)

# get library dirs for zlib and libbz2
get_filename_component(LIBBZ2_LIB_DIR ${BZIP2_LIBRARIES} DIRECTORY)
get_filename_component(ZLIB_LIB_DIR ${ZLIB_LIBRARIES} DIRECTORY)

set(B2_CONFIG_CONTENT "
using ${B2_TOOLCHAIN_TYPE} : ${B2_TOOLCHAIN_VERSION} : \"${CMAKE_CXX_COMPILER}\" :
<cflags>${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_${CMAKE_BUILD_TYPE}} ${OPT_CFLAGS_SPC}
<cxxflags>${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE}} ${OPT_CXXFLAGS_SPC}
<rc>${CMAKE_RC_COMPILER}
<archiver>${CMAKE_AR}
<ranlib>${CMAKE_RANLIB}
${SEARCH_PATHS} ;

using python : ${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR} : \"${PYTHON_EXECUTABLE}\" ;

using bzip2 : ${BZIP2_VERSION_STRING} : <include>${BZIP2_INCLUDE_DIR} <search>${LIBBZ2_LIB_DIR} ;
using zlib : ${ZLIB_VERSION_STRING} : <include>${ZLIB_INCLUDE_DIRS} <search>${ZLIB_LIB_DIR} ;

")

set(B2_CONFIG ${CMAKE_CURRENT_BINARY_DIR}/user-config.jam)
file(GENERATE OUTPUT ${B2_CONFIG} CONTENT "${B2_CONFIG_CONTENT}")

# set up directory structure
set(BOOTSTRAP_DIR ${CMAKE_CURRENT_BINARY_DIR}/bootstrap)
set(STAGE_DIR ${CMAKE_CURRENT_BINARY_DIR}/stage)
set(LIB_DIR ${CMAKE_CURRENT_BINARY_DIR}/stage/lib)

file(MAKE_DIRECTORY ${BOOTSTRAP_DIR} ${STAGE_DIR} ${LIB_DIR})


# import built libraries
# --------------------------------------------------------------------------------
set(BUILT_BOOST_LIBRARIES boost_chrono boost_filesystem boost_graph boost_iostreams
	boost_program_options boost_regex boost_system boost_thread boost_timer)

set(BOOST_LIBRARY_FULL_PATHS "")

foreach(LIBNAME ${BUILT_BOOST_LIBRARIES})

	set(LIB_FULL_PATH ${LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}${LIBNAME}${CMAKE_STATIC_LIBRARY_SUFFIX})
	list(APPEND BOOST_LIBRARY_FULL_PATHS ${LIB_FULL_PATH})

	# import the library
	add_library(${LIBNAME} STATIC IMPORTED GLOBAL)
	set_property(TARGET ${LIBNAME} PROPERTY IMPORTED_LOCATION ${LIB_FULL_PATH})
	set_property(TARGET ${LIBNAME} PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_CURRENT_SOURCE_DIR})

endforeach()

# header interface library
add_library(boost_headers INTERFACE)
set_property(TARGET boost_headers PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_CURRENT_SOURCE_DIR})

# some Boost libraries depend on other system libraries
set_property(TARGET boost_thread PROPERTY INTERFACE_LINK_LIBRARIES Threads::Threads)
set_property(TARGET boost_iostreams PROPERTY INTERFACE_LINK_LIBRARIES zlib bzip2)

# add external project
# --------------------------------------------------------------------------------


# NOTE: we allow bootstrap to pick its own compiler because the compiler the Amber is using
# may not be on the PATH or easily locatable on the host system, and (of course) there's
# no easy way to tell it the path to the compiler

set(BOOST_BUILD_COMMAND ${BOOTSTRAP_DIR}/b2${CMAKE_EXECUTABLE_SUFFIX}) # bootstrap.sh puts this here
set(BOOST_BUILD_ARGS
	--build-dir=${CMAKE_CURRENT_BINARY_DIR}/build # set build directory
	--stagedir=${STAGE_DIR} # set stage dir where build libraries are copied
	--ignore-site-config # ignore any system boost build config files
	--user-config=${B2_CONFIG} # use our config file
	--layout=system # disable tagging libraries with version or compiler
	--reconfigure # clear cache (in case incorrect info gets in the cache)
	link=static
	threading=multi
	variant=debug # only build debug libs, not release
	address-model=${B2_ADDRESS_MODEL} # only build libs for the target bitness
	toolset=${B2_TOOLCHAIN_TYPE}-${B2_TOOLCHAIN_VERSION} # use toolset defined in our custom config file

	# force boost_iostreams to enable bz2 and zlib support
	-sNO_BZIP2=0
	-sNO_ZLIB=0
	)

# libs for Amber to build
set(BOOST_LIB_ARGS
	--with-program_options
	--with-iostreams
	--with-regex
    --with-system
    --with-timer
    --with-chrono
    --with-filesystem
    --with-graph
    --with-thread)


set_property(DIRECTORY PROPERTY EP_BASE ${CMAKE_CURRENT_BINARY_DIR})
ExternalProject_Add(boost_build

	# directories
	SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}
	INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/install

	# no configure step
	CONFIGURE_COMMAND ""

	# build
	BUILD_COMMAND ${BOOST_BUILD_COMMAND} ${BOOST_BUILD_ARGS} ${BOOST_LIB_ARGS}
	BUILD_IN_SOURCE TRUE

	# no install command
	INSTALL_COMMAND ""
	BUILD_BYPRODUCTS ${BOOST_LIBRARY_FULL_PATHS}
	)

# custom bootstrap step
if(HOST_WINDOWS)

	# on Windows the bootstrap script has to be run from the boost folder
	ExternalProject_Add_Step(
		boost_build
		bootstrap
		COMMAND cmd /c bootstrap.bat gcc
		COMMAND cmake -E copy ${CMAKE_CURRENT_SOURCE_DIR}/b2.exe ${BOOST_BUILD_COMMAND}
		# clean up
		COMMAND cmake -E remove b2.exe bjam.exe project-config.jam
		COMMENT "Boostrapping Boost.Build (using machine default toolset)"
		DEPENDERS build
		BYPRODUCTS ${BOOST_BUILD_COMMAND}
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
		)

else()
	# on Unix the bootstrap script can be run from any folder and generates
	# its output in that folder.
	ExternalProject_Add_Step(
		boost_build
		bootstrap
		COMMAND ${BASH} ${CMAKE_CURRENT_SOURCE_DIR}/bootstrap.sh

		# remove project-config.jam if it had been generated by the legacy build system,
		# because it can screw up the build.
		COMMAND cmake -E remove ${CMAKE_CURRENT_SOURCE_DIR}/project-config.jam

		COMMENT "Boostrapping Boost.Build (using machine default toolset)"
		DEPENDERS build
		BYPRODUCTS ${BOOST_BUILD_COMMAND}
		WORKING_DIRECTORY ${BOOTSTRAP_DIR}
		)

endif()


foreach(LIBNAME ${BUILT_BOOST_LIBRARIES})
	add_dependencies(${LIBNAME} boost_build)
endforeach()
