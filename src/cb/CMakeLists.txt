add_executable(cb
  src/clipboard.cpp
  src/main.cpp
  src/themes.cpp
  src/indicator.cpp
  src/externalclipboards.cpp
  src/actions/add.cpp
  src/actions/clear.cpp
  src/actions/config.cpp
  src/actions/copy.cpp
  src/actions/edit.cpp
  src/actions/export.cpp
  src/actions/history.cpp
  src/actions/ignore.cpp
  src/actions/import.cpp
  src/actions/info.cpp
  src/actions/load.cpp
  src/actions/note.cpp
  src/actions/paste.cpp
  src/actions/pipeinout.cpp
  src/actions/remove.cpp
  src/actions/search.cpp
  src/actions/show.cpp
  src/actions/status.cpp
  src/actions/swap.cpp
  src/actions/undo.cpp
  src/actions/redo.cpp
  src/actions/script.cpp
  src/actions/share.cpp
  src/locales/en_us.cpp
  src/locales/es_co.cpp
  src/locales/es_do.cpp
  src/locales/pt_br.cpp
  src/locales/tr_tr.cpp
  src/locales/de_de.cpp
  src/locales/fr_fr.cpp
  src/utils/editors.cpp
  src/utils/utils.cpp
  src/utils/formatting.cpp
  src/utils/files.cpp
  src/utils/distance.cpp
  src/utils/directorysize.cpp
  src/utils/cowcopy.cpp
)

enable_lto(cb)

target_link_libraries(cb gui)

if(WIN32)
  target_sources(cb PRIVATE
    src/platforms/windows.cpp
    src/platforms/windows.manifest
  )
  target_compile_options(cb PRIVATE /utf-8)
elseif(APPLE)
  enable_language(OBJC)
  target_sources(cb PRIVATE
    src/platforms/macos.mm
  )
  target_link_libraries(cb "-framework AppKit")
  if(CMAKE_CXX_COMPILER_ID MATCHES "Clang" OR CMAKE_CXX_COMPILER_ID MATCHES "AppleClang")
    target_compile_options(cb PRIVATE -fobjc-arc)
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    target_compile_options(cb PRIVATE -fobjc-gc)
  endif()
elseif(HAIKU)
  target_sources(cb PRIVATE
    src/platforms/haiku.cpp
  )
  target_link_libraries(cb be)
elseif(ANDROID)
  target_sources(cb PRIVATE
    src/platforms/android.cpp
  )
elseif(X11WL)
  target_sources(cb PRIVATE src/platforms/x11wl.cpp)

  set_property(
    TARGET cb
    APPEND
    PROPERTY BUILD_RPATH
    "$ORIGIN"
  )
  set_property(
    TARGET cb
    APPEND
    PROPERTY INSTALL_RPATH
    "$ORIGIN"
  )
  set_property(
    TARGET cb
    APPEND
    PROPERTY BUILD_RPATH
    "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}"
  )
  set_property(
    TARGET cb
    APPEND
    PROPERTY INSTALL_RPATH
    "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}"
  )
  target_link_options(cb PRIVATE -z origin) # set the rpath to $ORIGIN
  
  target_link_libraries(cb ${CMAKE_DL_LIBS})
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -rdynamic") # needed for libs to access binary symbols
  if(NOT CMAKE_SYSTEM_NAME STREQUAL "OpenBSD")
    target_link_libraries(cb rt)
  endif()
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD" OR CMAKE_SYSTEM_NAME STREQUAL "OpenBSD" OR CMAKE_SYSTEM_NAME STREQUAL "NetBSD")
  target_sources(cb PRIVATE src/platforms/bsd.cpp)
endif()

if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
  target_sources(cb PRIVATE src/platforms/linux.cpp)
  # link liburing
  #target_link_libraries(cb uring)
endif()

if(ALSA_FOUND)
  target_link_libraries(cb asound)
endif()

set(CMAKE_THREAD_PREFER_PTHREAD True)
set(THREADS_PREFER_PTHREAD_FLAG True)
find_package(Threads REQUIRED)
target_link_libraries(cb Threads::Threads)

find_package(OpenSSL REQUIRED)
target_link_libraries(cb OpenSSL::Crypto)

install(TARGETS cb DESTINATION bin)

if(X11WL OR APPLE)
  install(FILES ${CMAKE_SOURCE_DIR}/documentation/manpages/man.1 DESTINATION share/man/man1 RENAME cb.1)
  find_program(FISH fish)
  if(FISH)
    install(FILES ${CMAKE_SOURCE_DIR}/documentation/completions/cb.fish DESTINATION share/fish/completions RENAME cb.fish)
  endif()
  find_program(BASH bash)
  if(BASH)
    install(FILES ${CMAKE_SOURCE_DIR}/documentation/completions/cb.bash DESTINATION share/bash-completion/completions RENAME cb)
  endif()
  find_program(ZSH zsh)
  if(ZSH)
    install(FILES ${CMAKE_SOURCE_DIR}/documentation/completions/cb.zsh DESTINATION share/zsh/site-functions RENAME _cb)
  endif()
endif()