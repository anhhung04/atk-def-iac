from libnum import ecc
import secrets
import hashlib
import os

p = 0xe6b2c1b3196d96e69e03a3d92094e2d03c81259a39095e046bd378d2e2074489
a = 0xe59dd4272c51a100537b706c566c30011ad09e5510019747bd0de4bd9460bf5a
b = 0x9ded60383a37aa799b540029b2bc2a3cd965e7f516664fcb8fa6905f329eeb59
n = 0xe6b2c1b3196d96e69e03a3d92094e2d03c81259a39095e046bd378d2e2074489
G = (0x381a82ab1ca32603390c1d917ec27aeb7067355a366e3f29077f2106a9e6c0b0,  0x0166bd7a8b2bb3b9751ce3bf63af19cf6b9c289cbb272179f7eed8bf6797efb9)
curve = ecc.Curve(a, b, p, G, n)

def generateKeyPair():
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

msg = "Hello, World!"
privkey, pubkey = generateKeyPair()
signature = sign(privkey, msg)
print(verify(pubkey, msg, signature))