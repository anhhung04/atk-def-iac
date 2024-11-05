from libnum import ecc
import secrets
import hashlib
import os

p = 0xE6B2C1B3196D96E69E03A3D92094E2D03C81259A39095E046BD378D2E2074489
a = 0xE59DD4272C51A100537B706C566C30011AD09E5510019747BD0DE4BD9460BF5A
b = 0x9DED60383A37AA799B540029B2BC2A3CD965E7F516664FCB8FA6905F329EEB59
n = 0xE6B2C1B3196D96E69E03A3D92094E2D03C81259A39095E046BD378D2E2074489
G = (
    0x381A82AB1CA32603390C1D917EC27AEB7067355A366E3F29077F2106A9E6C0B0,
    0x0166BD7A8B2BB3B9751CE3BF63AF19CF6B9C289CBB272179F7EED8BF6797EFB9,
)
curve = ecc.Curve(a, b, p, G, n)


def generate_key_pair():
    privkey = secrets.randbelow(n)
    pubkey = curve.power(G, privkey)
    return (privkey, pubkey)


def get_pubkey(privkey):
    return curve.power(G, privkey)


def sign(privkey, message):
    z = int(hashlib.sha1(message.encode()).hexdigest(), 16) % n
    k = int(hashlib.sha1(os.urandom(32)).hexdigest(), 16) % n
    R = curve.power(G, k)
    r = R[0]
    s = (z + r * privkey) * pow(k, -1, n) % n
    return (r, s)


def verify(pubkey, message, signature):
    z = int(hashlib.sha1(message.encode()).hexdigest(), 16) % n
    r, s = signature
    s_inv = pow(s, -1, n)
    u1 = z * s_inv % n
    u2 = r * s_inv % n
    R = curve.add(curve.power(G, u1), curve.power(pubkey, u2))
    return R[0] == r
