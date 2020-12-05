import Fs from 'fs';

const wsource = Fs.readFileSync('./example.wasm');
const wmodule = new WebAssembly.Module(wsource);

const env = {
  // memory: new WebAssembly.Memory({ initial: 1 }),
  js_print: (ptr, len) => {
    // console.log(`js_print: prt=${ptr}, len=${len}`);
    const slice = winstance.exports.memory.buffer.slice(ptr, ptr + len);
    const string = new TextDecoder('utf8').decode(slice);
    console.log(string);
  },
}

const winstance = new WebAssembly.Instance(wmodule, { env });

const string = 'hello';
var u8array = new Uint8Array(128);
u8array.set(new TextEncoder('utf8').encode(string), 0);
console.log('u8array=', new TextDecoder('utf8').decode(u8array));

console.log('count=', winstance.exports.count(u8array, u8array.length));

const len = 32;
const ptr = winstance.exports.newUint8Array(len);
if (ptr === 0) throw new Error('failed newUint8Array');
winstance.exports.getHello(ptr, len);
const slice = winstance.exports.memory.buffer.slice(ptr, ptr + len);
const text = new TextDecoder('utf8').decode(slice);
console.log(`text="${text}"`);

// allocate to death...
// while (winstance.exports.wasmalloc(1024 * 1024) != 0) { }
