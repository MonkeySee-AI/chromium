#!/bin/bash -e

if [ "$1" = "build" ]; then
    # Execute the rest of the Chromium build steps
    cd /srv/source/chromium

    # Sync the repository
    gclient sync --delete_unversioned_trees --revision $CHROMIUM_SHA --with_branch_heads

    # Run hooks
    gclient runhooks

    # Patching Chromium
    sed -i 's/^\(\s\+\)PLOG(WARNING) << "poll";$/\1PLOG(WARNING) << "poll"; failed_polls = 0;/' /srv/source/chromium/src/content/browser/sandbox_ipc_linux.cc
    sed -i 's/^\(\s*\)CHECK(render_process_host->InSameStoragePartition(.*$//*CHECK(render_process_host->InSameStoragePartition(browser_context->GetStoragePartition(site_instance, false)));*/' /srv/source/chromium/src/content/browser/renderer_host/render_process_host_impl.cc

    # Create the build configuration directory
    mkdir -p /srv/source/chromium/src/out/Default

    # Args was copied over to another location by the build stage
    mv /srv/source/chromium/args.gn /srv/source/chromium/src/out/Default/args.gn

    # Generate the build configuration
    RUN gn gen out/Default

    # Mounting the filesystem like this will require privileged execution of the docker container
    mount --types tmpfs --options size=100G,nr_inodes=256k,mode=1777 tmpfs /srv/source/chromium/src/out/Default

    # Compile Chromium
    autoninja -C out/Default chrome

    # Extract version information, strip symbols, and compress Chromium
    CHROMIUM_VERSION=$(sed -r 's~[^0-9]+~~g' chrome/VERSION | tr '\n' '.' | sed 's~[.]$~~')

    strip -o /srv/build/chromium/chromium-$CHROMIUM_VERSION out/Default/chrome

    brotli --best --force /srv/build/chromium/chromium-$CHROMIUM_VERSION

    # Archiving OpenGL ES driver
    tar --directory /srv/source/chromium/src/out/Default --create --file /srv/build/chromium/swiftshader.tar libEGL.so libGLESv2.so libvk_swiftshader.so libvulkan.so.1 vk_swiftshader_icd.json

    # Compressing OpenGL ES driver
    brotli --best --force /srv/build/chromium/swiftshader.tar

    # Final artifacts
    mv /srv/build/chromium/chromium-$CHROMIUM_VERSION.br /srv/build/chromium/chromium.br
    echo $CHROMIUM_VERSION > /srv/build/chromium/VERSION
else
    exec "$@"
fi
