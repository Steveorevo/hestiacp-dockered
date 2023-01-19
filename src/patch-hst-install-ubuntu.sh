#!/bin/php
<?php
/**
 * patch-hst-install-ubuntu.php
 *
 * Patches the hst-install-ubuntu.sh script to work with Ubuntu inside Docker by 
 * re-enforcing the use of our own systemd replacemnt after apt-get update & upgrades.
 *
 * @package HST
 * @subpackage Scripts
 * @version 1.0.0
 * @since 1.0.0
 */

/**
 * patch_file function. 
 * 
 * Tests if the given file exists and  does not contain the content of replace;
 * if missing it performs a search and replace on the file.
 * 
 * @param string $file The file to patch.
 * @param string $search The search string.
 * @param string $replace The replace string.
 */ 
function patch_file( $file, $search, $replace ) {
    if ( file_exists( $file ) && ! strstr( file_get_contents( $file ), $replace ) && strstr( file_get_contents( $file ), $search )) {
        $content = file_get_contents( $file );
        $content = str_replace( $search, $replace, $content );
        file_put_contents( $file, $content );
        echo "Patched $file with $replace\n";
    }
}

// Patch the hst-install-ubuntu.sh script
patch_file( 
    '/usr/src/hst-install-ubuntu.sh', 
    "# Update apt repository\napt-get -qq update\n",
    "# Update apt repository\napt-get -qq update\nrm /usr/bin/systemctl || true\nln -s /usr/bin/systemctl.sh /usr/bin/systemctl\n"
);

patch_file( 
    '/usr/src/hst-install-ubuntu.sh', 
    "# Updating system\necho -ne \"Updating currently installed packages, please wait... \"\napt-get -qq update\napt-get -y upgrade >> \$LOG &\nBACK_PID=\$!\n",
    "# Updating system\necho -ne \"Updating currently installed packages, please wait... \"\napt-get -qq update\napt-get -y upgrade >> \$LOG &\nBACK_PID=\$!\nrm /usr/bin/systemctl || true\nln -s /usr/bin/systemctl.sh /usr/bin/systemctl\n"
);

patch_file( 
    '/usr/src/hst-install-ubuntu.sh', 
    "# Update remaining packages since repositories have changed\necho -ne \"[ * ] Installing remaining software updates...\"\napt-get -qq update\napt-get -y upgrade >> \$LOG &\nBACK_PID=\$!\necho\n",
    "# Update remaining packages since repositories have changed\necho -ne \"[ * ] Installing remaining software updates...\"\napt-get -qq update\napt-get -y upgrade >> \$LOG &\nBACK_PID=\$!\necho\nrm /usr/bin/systemctl || true\nln -s /usr/bin/systemctl.sh /usr/bin/systemctl\n"
);
