// ES 2.0に移植したバージョン

precision mediump float;
uniform float time;
uniform vec2  resolution;

// 疑似乱数
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

// 遅延計算関数
float getDelayTime(float base, float diff, int id) {
    return base + diff * float(id);
}

// 点を描画する関数
float drawDot(vec2 pos, vec2 co, float r) {
    float d = sqrt(pow(pos.x - co.x, 2.0) + pow(pos.y - co.y, 2.0));
    return d < r ? 1.0 : 0.0;
}

// 十字を描画する関数
float drawCross(vec2 pos, vec2 co, float size, float bold) {
    float dx = abs(pos.x - co.x);
    float dy = abs(pos.y - co.y);

    if ((dx < size && dy < bold) || (dx < bold && dy < size)) {
        return 1.0;
    } else {
        return 0.0;
    }
}

// 正方形を描画する関数
float drawSquare(vec2 pos, vec2 co, float size, bool isLine, float bold) {
    float dx = abs(pos.x - co.x);
    float dy = abs(pos.y - co.y);

    if (dx < size && dy < size) {
        if (isLine) {
            if (size - bold < dx || size - bold < dy) {
                return 1.0;
            } else {
                return 0.0;
            }
        } else {
            return 1.0;
        }
    } else {
        return 0.0;
    }
}

// 枠線回転
float drawSquareOut(vec2 pos, vec2 cor, float size, float bold, float theta) {
    cor.x = cor.x * cos(theta) - cor.y * sin(theta);
    cor.y = cor.x * sin(theta) + cor.y * cos(theta);

    float dx = abs(pos.x - cor.x);
    float dy = abs(pos.y - cor.y);

    float r = 0.0;
    if ((dx < size && dy < size) && (dx > size - bold || dy > size - bold)) {
        r = 0.8 * abs(dx - (size - bold / 2.0)) + abs(dy - (size - bold / 2.0));
    }

    return length(r);
}

// 時間判定
bool isFitTime(float t, float u, float diff) {
    return abs(t - u) < diff;
}

// 文字のデータ
const vec2 ch_size  = vec2(1.0, 2.0) * 0.6;
const vec2 ch_space = ch_size + vec2(1.0, 1.0);
const vec2 ch_start = vec2 (ch_space.x * -5., 1.);

vec2 uv;
vec2 ch_pos   = vec2 (0.0, 0.0);

#define REPEAT_SIGN false
#define n0 ddigit(0x22FF);
#define n1 ddigit(0x0281);
#define n2 ddigit(0x1177);
#define n3 ddigit(0x11E7);
#define n4 ddigit(0x5508);
#define n5 ddigit(0x11EE);
#define n6 ddigit(0x11FE);
#define n7 ddigit(0x2206);
#define n8 ddigit(0x11FF);
#define n9 ddigit(0x11EF);

#define A ddigit(0x119F);
#define B ddigit(0x927E);
#define C ddigit(0x007E);
#define D ddigit(0x44E7);
#define E ddigit(0x107E);
#define F ddigit(0x101E);
#define G ddigit(0x807E);
#define H ddigit(0x1199);
#define I ddigit(0x4466);
#define J ddigit(0x4436);
#define K ddigit(0x9218);
#define L ddigit(0x0078);
#define M ddigit(0x0A99);
#define N ddigit(0x8899);
#define O ddigit(0x00FF);
#define P ddigit(0x111F);
#define Q ddigit(0x80FF);
#define R ddigit(0x911F);
#define S ddigit(0x8866);
#define T ddigit(0x4406);
#define U ddigit(0x00F9);
#define V ddigit(0x2218);
#define W ddigit(0xA099);
#define X ddigit(0xAA00);
#define Y ddigit(0x4A00);
#define Z ddigit(0x2266);
#define _ ch_pos.x += ch_space.x;
#define s_dot ddigit(0);
#define s_minus ddigit(0x1100);
#define s_plus ddigit(0x5500);
#define s_greater ddigit(0x2800);
#define s_less ddigit(0x8200);
#define s_sqrt ddigit(0x0C02);
#define nl1 ch_pos = ch_start; ch_pos.y -= 3.0;
#define nl2 ch_pos = ch_start; ch_pos.y -= 6.0;
#define nl3 ch_pos = ch_start; ch_pos.y -= 9.0;

float dseg(vec2 p0, vec2 p1) {
	vec2 dir = normalize(p1 - p0);
	vec2 cp = (uv - ch_pos - p0) * mat2(dir.x, dir.y,-dir.y, dir.x);
	return distance(cp, clamp(cp, vec2(0), vec2(distance(p0, p1), 0)));
}

bool bit(int n, int b) {
	return mod(floor(float(n) / exp2(floor(float(b)))), 2.0) != 0.0;
}

float d = 1e6;

void ddigit(int n) {
	float v = 1e6;
	vec2 cp = uv - ch_pos;
	if (n == 0) v = min(v, dseg(vec2(-0.405, -1.000), vec2(-0.500, -1.000)));
	if (bit(n, 0)) v = min(v, dseg(vec2( 0.500, 0.063), vec2( 0.500, 0.937)));
	if (bit(n, 1)) v = min(v, dseg(vec2( 0.438, 1.000), vec2( 0.063, 1.000000000)));
	if (bit(n, 2)) v = min(v, dseg(vec2(-0.063, 1.000), vec2(-0.438, 1.000)));
	if (bit(n, 3)) v = min(v, dseg(vec2(-0.500, 0.937), vec2(-0.500, 0.062)));
	if (bit(n, 4)) v = min(v, dseg(vec2(-0.500, -0.063), vec2(-0.500, -0.938)));
	if (bit(n, 5)) v = min(v, dseg(vec2(-0.438, -1.000), vec2(-0.063, -1.000)));
	if (bit(n, 6)) v = min(v, dseg(vec2( 0.063, -1.000), vec2( 0.438, -1.000)));
	if (bit(n, 7)) v = min(v, dseg(vec2( 0.500, -0.938), vec2( 0.500, -0.063)));
	if (bit(n, 8)) v = min(v, dseg(vec2( 0.063, 0.000), vec2( 0.438, -0.000)));
	if (bit(n, 9)) v = min(v, dseg(vec2( 0.063, 0.063), vec2( 0.438, 0.938)));
	if (bit(n, 10)) v = min(v, dseg(vec2( 0.000, 0.063), vec2( 0.000, 0.937)));
	if (bit(n, 11)) v = min(v, dseg(vec2(-0.063, 0.063), vec2(-0.438, 0.938)));
	if (bit(n, 12)) v = min(v, dseg(vec2(-0.438, 0.000), vec2(-0.063, -0.000)));
	if (bit(n, 13)) v = min(v, dseg(vec2(-0.063, -0.063), vec2(-0.438, -0.938)));
	if (bit(n, 14)) v = min(v, dseg(vec2( 0.000, -0.938), vec2( 0.000, -0.063)));
	if (bit(n, 15)) v = min(v, dseg(vec2( 0.063, -0.063), vec2( 0.438, -0.938)));
	ch_pos.x += ch_space.x;
	d = min(d, v);
}

// 円アニメーション
#define firstAnimeMax 20

void main(void) {
    // ランダム生成したアニメーションステータス
    float vertex[20], size[20], bold[20], crossX[20], crossY[20];

    vertex[0] = 3.0;
    vertex[1] = 7.0;
    vertex[2] = 6.0;
    vertex[3] = 7.0;
    vertex[4] = 3.0;
    vertex[5] = 3.0;
    vertex[6] = 3.0;
    vertex[7] = 5.0;
    vertex[8] = 4.0;
    vertex[9] = 4.0;
    vertex[10] = 7.0;
    vertex[11] = 6.0;
    vertex[12] = 7.0;
    vertex[13] = 5.0;
    vertex[14] = 5.0;
    vertex[15] = 9.0;
    vertex[16] = 5.0;
    vertex[17] = 3.0;
    vertex[18] = 8.0;
    vertex[19] = 9.0;

    size[0] = 0.8517728284589056;
    size[1] = 0.437823408293741;
    size[2] = 0.2767909359551174;
    size[3] = 0.22989810413781597;
    size[4] = 0.5195013517701023;
    size[5] = 0.9413025031204734;
    size[6] = 1.1006632553158637;
    size[7] = 0.7219629074791296;
    size[8] = 0.3448107443309676;
    size[9] = 0.5821546464548707;
    size[10] = 0.7716910778327752;
    size[11] = 1.0419468130901572;
    size[12] = 0.7225763957386716;
    size[13] = 1.0330138177736934;
    size[14] = 0.6661509950164352;
    size[15] = 0.568596703949872;
    size[16] = 0.9853028107106818;
    size[17] = 1.136085667364842;
    size[18] = 0.8715578351696774;
    size[19] = 0.491735118269912;

    bold[0] = 0.36605860373401444;
    bold[1] = 0.21003121872298278;
    bold[2] = 0.148497159815699;
    bold[3] = 0.011828186127850962;
    bold[4] = 0.18280377581377355;
    bold[5] = 0.21262058035100256;
    bold[6] = 0.5630728010489193;
    bold[7] = 0.01681244800235683;
    bold[8] = 0.16064822407106757;
    bold[9] = 0.6406931589878424;
    bold[10] = 0.6860159856479536;
    bold[11] = 0.6371189891452668;
    bold[12] = 0.2832188237255471;
    bold[13] = 0.6446821192094964;
    bold[14] = 0.6558640317607947;
    bold[15] = 0.124457407672477;
    bold[16] = 0.2619644284911844;
    bold[17] = 0.150808068845231;
    bold[18] = 0.09314947003599028;
    bold[19] = 0.586744675628687;

    crossX[0] = -0.08610518714887139;
    crossX[1] = -0.6435422165007387;
    crossX[2] = -0.8649901672514777;
    crossX[3] = -0.9797820462883067;
    crossX[4] = -0.9013240044009305;
    crossX[5] = 0.540649841553869;
    crossX[6] = 0.5592064987908043;
    crossX[7] = 0.07871545171406025;
    crossX[8] = 0.9596001425062255;
    crossX[9] = -0.36637779896494216;
    crossX[10] = 0.9165140079517808;
    crossX[11] = -0.3799936966140196;
    crossX[12] = -0.6527110128676652;
    crossX[13] = -0.345671131338932;
    crossX[14] = 0.5399305174895224;
    crossX[15] = 0.4272623364149415;
    crossX[16] = 0.30453987917248604;
    crossX[17] = -0.894115181850625;
    crossX[18] = 0.7897113099592827;
    crossX[19] = -0.33761221513288353;

    crossY[0] = 0.48535766044698514;
    crossY[1] = 0.10288797292901997;
    crossY[2] = 0.5232517588399008;
    crossY[3] = 0.005454256548908187;
    crossY[4] = -0.854093953128571;
    crossY[5] = 0.19137431157662554;
    crossY[6] = 0.15619375666423396;
    crossY[7] = 0.7260114768765846;
    crossY[8] = 0.7371965807962368;
    crossY[9] = -0.08592785178249995;
    crossY[10] = -0.4048314323225144;
    crossY[11] = 0.4686373498497094;
    crossY[12] = 0.21007428802104489;
    crossY[13] = 0.2339634270662434;
    crossY[14] = -0.3620921757837916;
    crossY[15] = -0.26185260509534514;
    crossY[16] = 0.6348054098057472;
    crossY[17] = -0.4799540511656537;
    crossY[18] = 0.6480520378191748;
    crossY[19] = 0.03806044602562775;

    vec2 p = (gl_FragCoord.xy * 2.0 - resolution) / min(resolution.x, resolution.y);

    // 詳細なアニメーションステータス
    int type = 0;
    float t, u;

    // テキストステータス
    vec2 aspect = resolution.xy / resolution.y;
    uv = (gl_FragCoord.xy / resolution.y) - aspect / 2.0;

    float _d =  1.0-length(uv);
    uv *= 10.0 ;
    uv.y += 1.0;

    t = 0.0;

    // 冒頭のドラムに合わせて図形を表示するシーン
    if (time >= 0.2) {
        for (int i = firstAnimeMax; i > 0; i--) {
            if (time < getDelayTime(0.0, 0.08, i)) {
                u = sin((atan(p.y, p.x) - time * 0.4) * vertex[i - 1]) * 0.01;
                t = bold[i - 1] * 0.1 / abs((size[i - 1] - 0.16) * 1.2 + u - length(p));

                // ドットマップ、クロスマップ、正方形を描画する
                for (float drawY = 0.0; drawY < 6.0; drawY++) {
                    for (float drawX = 0.0; drawX < 3.0; drawX++) {
                        t += drawCross(vec2(crossX[i] * 1.8 + drawX * 0.06, crossY[i] + drawY * 0.06), p, 0.02, 0.003);

                        t += drawSquare(vec2(-crossX[i], -crossY[i]), p, 0.05, true, 0.01);
                        t += drawSquare(vec2(-crossX[i], crossY[i]), p, 0.11, true, 0.01);

                        for (float y = 0.0; y < 4.0; y++) {
                            for (float x = 0.0; x < 6.0; x++) {
                                t += drawDot(vec2(crossX[i] * 2.2 + x * 0.08, crossY[i] * -1.4 + y * 0.08), p, 0.005);
                            }
                        }
                    }
                }

                t += rand(gl_FragCoord.xy) * 0.03;
                t *= time * 2.7;
            }
        }
    }

    // ドラム後にぐるぐる巻きを表示するシーン
    if (time >= 1.8) {
        type = 1;

        // 3段階変化
        if (time >= 3.76) {
            if (time <= 5.6) {
                u = sin((atan(p.x, p.y) + 4.0) * 8.0) * 0.01;
                t = 0.05 / abs(0.5 + u - length(p));
            }
        } else if (time >= 3.46) {
            u = sin((atan(p.x, p.y) + 4.0) * 3.0) * 0.01;
            t = 0.16 / abs(0.9 + u - length(p));
        } else {
            u = sin((atan(p.x, p.y) + 4.0) * 16.0) * 0.01;
            t = 0.02 / abs(0.2 + u - length(p));
        }

        float size[8];
        size[0] = 0.05;
        size[1] = 0.12;
        size[2] = 0.08;
        size[3] = 0.18;
        size[4] = 0.06;
        size[5] = 0.09;
        size[6] = 0.15;
        size[7] = 0.07;

        for (int i = 0; i < 8; i++) {
            float timeA = abs(time - getDelayTime(3.2, 0.034, i));
            float timeB = abs(time - getDelayTime(4.7, 0.034, i));

            if (timeA < 0.07 || timeB < 0.07) {
                t += drawSquare(vec2(crossX[i] * 1.4, -crossY[i] * 1.2), p, size[i], true, 0.01);
                t += drawSquare(vec2(-crossX[i] * 2.4, crossY[i] * 1.2), p, size[i], true, 0.01);
            }
        }

        if (time <= 6.8) {
            float vertex = floor(7.0 * time);
            if (mod(vertex, 2.0) == 1.0) vertex++;

            u = abs(sin((atan(p.y, p.x) - length(p) + time * 1.8) * vertex) * 2.4) + 0.2;
            t += 0.03 / abs(u - length(p));
        }

        for (float i = 0.0; i < 10.0; i++) {
            t += drawSquareOut(vec2(0, 0), p, 0.1 + (i + 1.0) * 0.1, 0.05, mod(time + (i + 1.0) * 16.0, 360.0) * (0.8 * (i + 0.5) * 0.16)) * 0.5;
        }
    }

    // メロラインに合わせて画面を変化
    if (time >= 5.1) {
        type = 2;

        if (time <= 7.3) {
            float color = drawSquare(vec2(0.0), p, 0.67, true, 0.2);
            bool isArea = false;

            if (color == 1.0) {
                isArea = true;

                type = 0;
                t = color;
            }

            if (time <= 6.2 && time >= 5.6) {
                color = drawSquare(vec2(0.0), p, 0.97, true, 0.2);
                if (!isArea && color == 1.0) {
                    type = 0;
                    t = color;
                }
            }
        }
    }

    if (time >= 7.8) {
        u = cos((atan(p.x, p.y) + 4.0) * 8.0) * 0.01 + time;
        t = 0.05 / abs(0.5 + u - length(p));

        // ch_pos = ch_start;
        // _ _ _ _ G O s_greater
        // t += 1.0 - (0.04 / d*2.0);

        bool isDraw = false;
        ch_pos = ch_start;

        if (isFitTime(time, 8.7, 0.06)) {
            isDraw = true;
            _ _ _ _ n2
        } else if (isFitTime(time, 9.0, 0.09)) {
            isDraw = true;
            _ _ _ _ _ n0
        } else if (isFitTime(time, 9.3, 0.09)) {
            isDraw = true;
            _ _ _ _ _ _  n1
        } else if (isFitTime(time, 9.6, 0.09)) {
            isDraw = true;
            _ _ _ _ n9
        } else if (isFitTime(time, 9.9, 0.09)) {
            isDraw = true;
            _ _ _ _ G O s_greater
        }

        if (time > 10.2) {
            _ _ _ S T A R T

            float textPower = 1.0 - (0.04 / d*2.0);
            if (textPower > (time - 10.0) * 0.46) {
                t = 1.0 - length(textPower);
            } else {
                t = 0.0;
            }

            type = 0;
        } else {
            if (isDraw) {
                float textPower = 1.0 - (0.04 / d*2.0);
                if (textPower > 0.1) {
                    t =  1.0 - length(textPower);
                    type = 0;
                }
            }
        }
    }

    // レンダリング
    vec4 color;

    if (type == 0) color = vec4(vec3(t), 1.0);
    if (type == 1) color = vec4(0.0, t * 0.6, t, 1.0);
    if (type == 2) color = vec4(0.05, 0.05 + t * 0.6, 0.05 + t, 1.0);

    gl_FragColor = color;
}