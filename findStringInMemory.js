/* 
 * Replace those null bytes with your own pattern
 * You can obtain them like so $ echo -n 'Testing' | hexdump
*/

var pattern = '00 00 00 00 00 00' // Replace it with your own

var modules = Process.enumerateModules();

var mName = "";

for(var i = 0; i < modules.length; i++) {
	mName = modules[i].name;
	Memory.scan(modules[i].base, modules[i].size, pattern, {
  		onMatch(address, size) {
		console.log('[*] Found match in', mName, 'at', address, '(', size,') bytes');
		console.log('[*] Hexdump of string')
		console.log('\t\t', hexdump(address, {length: size, header: false}));
  	},
  		onComplete() {
  		}
	});
}
