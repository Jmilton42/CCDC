import random, hashlib

def hex2bigint(val):
    val = bytes.fromhex(val)
    ret = 0
    for i in val:
        ret = (ret << 8) | i
    return ret

def trun64(val):
    return val & 0xFFFFFFFFFFFFFFFF

def rol64(x, k):
    return trun64(x << k) | trun64(x >> (64 - k))

def bigIntToU64Array(val):
    ret = []
    while val != 0:
        ret.append(val & 0xFFFFFFFFFFFFFFFF)
        val >>= 64
    return ret

def u64ArrayToBigInt(arr: list[int]):
    ret = 0
    for i in reversed(arr):
        ret <<= 64
        ret += trun64(i)
    return ret

def randBigInt():
    return random.randint(0,2 ** 256 - 1)

# Constants for word generation
consonants = ["b","k","d","f","g","h","j","l","m","n","p","r","s","t","v","w","y","z","bl","cl","fl","gl","pl","br","cr","dr","fr","gr","pr","tr","sk","sl","sp","st","sw","spr","str","ch","sh","th","th","wh","ng","nk"];
vowels = ["a","e","i","o","u","oo","oi","ow","ey","oo","aw"];
symbols = ["!", "@", "#", "$", "%", "^", "&", "*", "?", "_", "-", "+", "="];

class XorshiftGenerator():
    def __init__(self, seed, size=256):
        if type(seed) == str:
            seed = seed.encode()
        
        if type(seed) == bytes:
            seed = hex2bigint(hashlib.sha256(seed).hexdigest())
        
        self.state = seed
        self.size = size
    
    def advance(self, rounds=1):
        s = bigIntToU64Array(self.state)
        result = None
        for _ in range(rounds):
            result = trun64(rol64(s[1] * 5, 7) * 9)
            t = s[1] << 17

            s[2] ^= s[0]
            s[3] ^= s[1]
            s[1] ^= s[2]
            s[0] ^= s[3]

            s[2] ^= t
            s[3] = rol64(s[3], 45)

        self.state = u64ArrayToBigInt(s)
        return result

    def advance256(self, rounds=1):
        value = self.advance(rounds)
        return (value >> ((value >> 58) % 56)) & 255

    def choice(self, iter):
        return iter[self.advance256() % len(iter)]


    def join(self, words, delimiters):
        ret = []
        for i in words:
            ret.append(i)
            ret.append(self.choice(delimiters))
        return ''.join(ret[0:len(ret) - 1])

    def genWord(self, length=5):
        ret = []
        for i in range(length):
            ret.append(self.choice(vowels if i % 2 else consonants))
        return ''.join(ret)

    def genPassword(self, words=2, numbers=1):
        ret = []
        for i in range(words):
            ret.append(self.genWord())
        
        for i in range(numbers):
            numArray = []
            for j in range(4):
                numArray.append(self.advance256() % 10)
            ret.append(''.join(str(i) for i in numArray))
        return self.join(ret, symbols)


def genPassword(seed: str|bytes|int, rounds: int) -> str:
    '''
    Generates a password based on the seed and the number of rounds.
    Just a wrapper for the class.
    '''
    prng = XorshiftGenerator(seed)
    prng.advance(rounds)
    return prng.genPassword()

if __name__ == "__main__":
    from getpass import getpass
    from sys import argv

    if len(argv) == 1:
        print(genPassword(
            getpass("Seed: "),
            int(input("Rounds: "))
        ))
    elif len(argv) == 2:
        seed = getpass("Seed: ")
        rounds = int(input("Rounds: "))
        with open(argv[1], "r") as inFile:
            for line in inFile:
                name = line.strip()
                print(name, genPassword(
                    seed + name,
                    rounds
                ), sep=':')
    else:
        print(f"USAGE: {argv[0]} [USERS_PATH]")

