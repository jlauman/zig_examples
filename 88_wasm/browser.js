window.TheWasm = {
  run: () => {
    let winstance;
    const env = {
      js_print: (ptr, len) => {
        // console.log(`js_print: prt=${ptr}, len=${len}`);
        const slice = winstance.exports.memory.buffer.slice(ptr, ptr + len);
        const string = new TextDecoder('utf8').decode(slice);
        console.log(string);
      },
    }
    WebAssembly.instantiateStreaming(fetch('example.wasm'), { env })
      .then(object => {
        winstance = object.instance;

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
      });
  }
}
