(() => {
    onload = () => {
        const bgm = {
            opening: new Audio('./asset/sound/edmhaywyre-insight.mp3'),
            ending: new Audio('./asset/sound/Teminite & Panda Eyes - Highscore.mp3')
        };

        const pageList = document.getElementById('page-list');
        const pageNumber = document.getElementById('page-number');

        const status = {
            page: {
                now: 0,
                max: 0
            },

            vjmode: false
        };

        const keyBuffer = [];

        const pageXhr = new XMLHttpRequest();
        const slideXhr = new XMLHttpRequest();
        const shaderXhr = new XMLHttpRequest();

        pageXhr.open('GET', './asset/json/page.json');
        slideXhr.open('GET', './asset/json/slide.json');
        shaderXhr.open('GET', './asset/json/shader.json');

        pageXhr.onload = () => {
            slideXhr.onload = () => {
                shaderXhr.onload = () => {
                    const pageJson = JSON.parse(pageXhr.responseText);
                    const slideJson = JSON.parse(slideXhr.responseText);
                    const shaderJson = JSON.parse(shaderXhr.responseText);

                    status.page.max = Object.keys(pageJson).length;

                    const renderPage = id => {
                        console.clear();
                        console.log('Start render DOM');

                        status.vjmode = false;
                        pageNumber.innerText = `${id + 1} / ${status.page.max + 1}`;

                        Object.keys(bgm).map(key => {
                            const soSilent = setInterval(() => {
                                console.log('OK');
                                bgm[key].volume += (0 - bgm[key].volume) / 8;
                                if (bgm[key].volume < 0.1) {
                                    clearInterval(soSilent);

                                    bgm[key].pause();
                                    bgm[key].currentTime = 0;
                                }
                            }, 30);
                        });

                        const renderdDom = document.getElementsByClassName('renderd-dom');
                        if (renderdDom) [...renderdDom].map(dom => document.body.removeChild(dom));

                        // render dom
                        slideJson[id].map(data => {
                            const dom = document.createElement(data.dom);
                            dom.style.pointerEvents = 'none';
                            dom.classList.add('renderd-dom');

                            if (data.src) dom.src = data.src;
                            dom.innerHTML = data.text || '';

                            document.body.appendChild(dom);

                            let stack = null;
                            if (data.css) {
                                data.css.map((data, index) => {
                                    if (index % 2 == 1) {
                                        console.log(stack, ':', data);
                                        dom.style[stack] = data;
                                    } else {
                                        stack = data;
                                    }
                                });
                            }
                        });

                        // rendering
                        if (shaderJson[id] != undefined) {
                            status.vjmode = true;
                            console.log('Start compile shader');

                            // compile shader
                            const path = `./asset/glsl/${shaderJson[id]}/`;

                            const vertexShaderXhr = new XMLHttpRequest();
                            const fragmentShaderXhr = new XMLHttpRequest();

                            vertexShaderXhr.open('GET', `${path}vertex.glsl`);
                            fragmentShaderXhr.open('GET', `${path}fragment.glsl`);

                            vertexShaderXhr.onload = () => {
                                fragmentShaderXhr.onload = () => {
                                    // running then onloaded v-shader and f-shader
                                    const vertexShader = vertexShaderXhr.responseText;
                                    const fragmentShader = fragmentShaderXhr.responseText;

                                    const canvas = document.getElementsByTagName('canvas')[0];
                                    const height = innerHeight * 0.75;
                                    const width = innerWidth * 0.65;

                                    canvas.height = height;
                                    canvas.width = width;

                                    const ctx = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');

                                    const program = createProgram(createShader(vertexShader, 'v'), createShader(fragmentShader, 'f'));

                                    const uniform = [];
                                    uniform[0] = ctx.getUniformLocation(program, 'time');
                                    uniform[1] = ctx.getUniformLocation(program, 'resolution');

                                    const position = [
                                        -1.0, 1.0, 0.0,
                                        1.0, 1.0, 0.0,
                                        -1.0, -1.0, 0.0,
                                        1.0, -1.0, 0.0
                                    ];

                                    const index = [
                                        0, 2, 1,
                                        1, 2, 3
                                    ];

                                    const vbo_Index = createIbo(index);
                                    const vbo_Position = createVbo(position);
                                    const vbo_AttLocation = ctx.getAttribLocation(program, 'position');

                                    ctx.bindBuffer(ctx.ARRAY_BUFFER, vbo_Position);
                                    ctx.enableVertexAttribArray(vbo_AttLocation);
                                    ctx.vertexAttribPointer(vbo_AttLocation, 3, ctx.FLOAT, false, 0, 0);
                                    ctx.bindBuffer(ctx.ELEMENT_ARRAY_BUFFER, vbo_Index);
                                    ctx.clearColor(0.0, 0.0, 0.0, 1.0);

                                    // start
                                    let time = null;
                                    setTimeout(() => {
                                        if (status.vjmode) {
                                            if (bgm[shaderJson[id]]) {
                                                bgm[shaderJson[id]].play();
                                                bgm[shaderJson[id]].volume = 1;
                                            }

                                            time = new Date().getTime();
                                            tick();
                                        }
                                    }, 700);

                                    function tick() {
                                        const sec = (new Date().getTime() - time) / 1000;
                                        ctx.clear(ctx.COLOR_BUFFER_BIT);

                                        // pageNumber.innerText = sec;

                                        ctx.uniform1f(uniform[0], sec);
                                        ctx.uniform2fv(uniform[1], [width, height]);

                                        ctx.drawElements(ctx.TRIANGLES, 6, ctx.UNSIGNED_SHORT, 0);
                                        ctx.flush();

                                        time++;
                                        if (status.vjmode) requestAnimationFrame(tick);
                                    }

                                    // function of compile setup
                                    function createProgram(vs, fs) {
                                        let stack = ctx.createProgram();

                                        ctx.attachShader(stack, vs);
                                        ctx.attachShader(stack, fs);
                                        ctx.linkProgram(stack);

                                        if (ctx.getProgramParameter(stack, ctx.LINK_STATUS)) {
                                            console.log('Success <create program>');
                                            ctx.useProgram(stack);
                                            return stack;
                                        } else {
                                            return null;
                                        }
                                    }

                                    function createShader(script, type) {
                                        let shader = null;
                                        if (type == 'v') shader = ctx.createShader(ctx.VERTEX_SHADER);
                                        if (type == 'f') shader = ctx.createShader(ctx.FRAGMENT_SHADER);

                                        ctx.shaderSource(shader, script);
                                        ctx.compileShader(shader);

                                        if (ctx.getShaderParameter(shader, ctx.COMPILE_STATUS)) {
                                            console.log('Success <create shader>');
                                            return shader;
                                        } else {
                                            alert(ctx.getShaderInfoLog(shader));
                                            console.log(ctx.getShaderInfoLog(shader));
                                        }
                                    }

                                    function createVbo(data) {
                                        let vbo = ctx.createBuffer();
                                        ctx.bindBuffer(ctx.ARRAY_BUFFER, vbo);
                                        ctx.bufferData(ctx.ARRAY_BUFFER, new Float32Array(data), ctx.STATIC_DRAW);
                                        ctx.bindBuffer(ctx.ARRAY_BUFFER, null);

                                        return vbo;
                                    }

                                    function createIbo(data) {
                                        let ibo = ctx.createBuffer();
                                        ctx.bindBuffer(ctx.ELEMENT_ARRAY_BUFFER, ibo);
                                        ctx.bufferData(ctx.ELEMENT_ARRAY_BUFFER, new Int16Array(data), ctx.STATIC_DRAW);
                                        ctx.bindBuffer(ctx.ELEMENT_ARRAY_BUFFER, null);

                                        return ibo;
                                    }
                                };

                                fragmentShaderXhr.send(null);
                            };

                            vertexShaderXhr.send(null);
                        }
                    };

                    // start
                    renderPage(status.page.now);

                    // render page list
                    Object.keys(pageJson).map((key, index) => {
                        const div = document.createElement('div');
                        div.classList.add('page-list-item');
                        div.innerText = pageJson[key];
                        pageList.appendChild(div);

                        div.addEventListener('click', () => {
                            if (status.page.now != index) {
                                status.page.now = index;
                                renderPage(index);
                            }
                        });
                    });

                    // setup keybind
                    document.addEventListener('keydown', e => {
                        const beforePage = status.page.now;
                        keyBuffer[e.keyCode] = true;

                        if ((keyBuffer[37] || keyBuffer[38]) && status.page.now > 0) status.page.now --;
                        if ((keyBuffer[39] || keyBuffer[40]) && status.page.now < status.page.max) status.page.now++;

                        if (beforePage != status.page.now) {
                            renderPage(status.page.now);
                        }
                    });

                    document.addEventListener('keyup', e => {
                        keyBuffer[e.keyCode] = false;
                    });
                }

                shaderXhr.send(null);
            }

            slideXhr.send(null);
        };

        pageXhr.send(null);
    };
})();
