#!/bin/sh

usage() {
	echo "Usage:\t\t./skeleton.sh <method> <outputJSFile>"
	echo "Example:\t./skeleton.sh '-[RootCheckResult isRooted]' script.js"
}

if [[ $# -ne 2 ]]; then
	usage
	exit 1
fi

METHOD="$1"
FILENAME="$2"

echo "$METHOD" | sed -E 's/([-+])\[(.*) (.*)\]/var impl = ObjC.classes.\2["\1 \3"];/' > "$FILENAME"

cat >> "$FILENAME" << EOF

Interceptor.attach(impl.implementation, {
	onEnter: function(args) {
		console.log("Got called");
	},
	onLeave: function(retval) {
		console.log("Leaving function, retval is => " + retval);
	}
});
EOF


