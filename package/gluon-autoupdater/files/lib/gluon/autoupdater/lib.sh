# Library to be sourced by download.d/abort.d scripts


stop() {
        if [ -x /etc/init.d/$1 ]; then
                echo "Stopping $1..."
                /etc/init.d/$1 stop
        fi
}

start_enabled() {
        if [ -x /etc/init.d/$1 ] && /etc/init.d/$1 enabled; then
                echo "Starting $1..."
                /etc/init.d/$1 start
        fi
}
