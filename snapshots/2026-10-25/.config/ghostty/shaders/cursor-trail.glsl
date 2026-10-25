// Cursor trail: when the cursor jumps, a glowing, flickering streak shoots from
// where it was to where it lands, then fades. At rest, a soft glow pulses
// around the cursor. Typing (one-cell moves) leaves no streak.

const float TRAIL_TIME   = 0.35;  // seconds for the streak to catch up and fade
const float MIN_JUMP     = 2.0;   // in cursor widths; shorter moves leave no streak
const float FLICKER      = 0.35;  // 0 = steady streak, 1 = strong electric flicker
const float GLOW_SIZE    = 10.0;  // pixels of halo around the cursor at rest
const float GLOW_STRENGTH = 0.5;  // 0 = no halo, 1 = full cursor colour
const float PULSE_PERIOD = 2.0;   // seconds per halo pulse

// Distance from p to the segment a-b; h is where along it (0 at a, 1 at b).
float sdSegment(vec2 p, vec2 a, vec2 b, out float h) {
    vec2 pa = p - a, ba = b - a;
    h = clamp(dot(pa, ba) / max(dot(ba, ba), 1e-6), 0.0, 1.0);
    return length(pa - ba * h);
}

// Distance from p to a box (negative inside).
float sdBox(vec2 p, vec2 center, vec2 halfSize) {
    vec2 d = abs(p - center) - halfSize;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float hash(float n) {
    return fract(sin(n) * 43758.5453);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 color = texture(iChannel0, fragCoord / iResolution.xy);
    if (iFocus == 0) {
        fragColor = color;
        return;
    }

    // Cursor rects: xy = left/top corner (pixels, y up), zw = width/height
    vec4 cur = iCurrentCursor;
    vec4 prev = iPreviousCursor;
    vec2 halfSize = cur.zw * 0.5;
    vec2 curCenter = cur.xy + vec2(halfSize.x, -halfSize.y);
    vec2 prevCenter = prev.xy + vec2(prev.z * 0.5, -prev.w * 0.5);
    vec3 tint = iCurrentCursorColor.rgb;

    float since = iTime - iTimeCursorChange;
    float p = clamp(since / TRAIL_TIME, 0.0, 1.0);
    float effect = 0.0;

    // The streak: its tail races toward the cursor (ease-out) while it fades
    if (length(curCenter - prevCenter) > MIN_JUMP * cur.z && p < 1.0) {
        float ease = 1.0 - pow(1.0 - p, 3.0);
        vec2 tail = mix(prevCenter, curCenter, ease);
        float h;
        float d = sdSegment(fragCoord, tail, curCenter, h);
        float radius = mix(0.15, 0.5, h) * cur.w;   // thin at the tail, cursor-tall at the head
        float core = 1.0 - smoothstep(radius * 0.6, radius, d);
        float glow = exp(-max(d - radius, 0.0) / (0.4 * cur.w));
        float flicker = 1.0 - FLICKER + FLICKER * hash(floor(iTime * 40.0) + floor(h * 12.0));
        effect = max(core, glow * 0.6) * flicker * (1.0 - p);
    }

    // The halo: only outside the cursor, and only once the streak has settled
    float dBox = sdBox(fragCoord, curCenter, halfSize);
    if (dBox > 0.0) {
        float pulse = 0.5 + 0.5 * cos(6.2831853 * since / PULSE_PERIOD);
        float settle = smoothstep(TRAIL_TIME, TRAIL_TIME + 0.3, since);
        effect = max(effect, exp(-dBox / (GLOW_SIZE * 0.5)) * pulse * GLOW_STRENGTH * settle);
    }

    color.rgb = mix(color.rgb, tint, clamp(effect, 0.0, 1.0));
    fragColor = color;
}
