/* 
 * Replace those null bytes with your own pattern
 * You can obtain them like so $ echo -n 'Testing' | hexdump
 *
 * Then just load it into your target, using -l parameter like 
 * $ frida -U Gadget -l findStringInMemory.js
	[*] Found match in dyld at 0x10d180f88 ( 7 ) bytes
	[*] Hexdump of string
		 10d180f88  54 65 73 74 69 6e 67                             Testing
*/

var pattern = '31 32 33 34' // Replace it with your own

var modules = Process.enumerateModules();

var mName = "";

for(var i = 0; i < modules.length; i++) {
	mName = modules[i].name;
	Memory.scan(modules[i].base, modules[i].size, pattern, {
  		onMatch(address, size) {
		console.log('[*] Found match in', mName, 'at', address, '(', size,') bytes');
		console.log('[*] Hexdump of string')
		console.log(hexdump(address, {header: false}))
  	},
  		onComplete() {
  		}
	});
}
