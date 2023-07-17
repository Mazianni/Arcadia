extends RefCounted
class_name JWTAlgorithm

var _alg: int = -1
var _secret: String = ""

var crypto: Crypto = Crypto.new()
var _public_crypto: CryptoKey = CryptoKey.new()
var _private_crypto: CryptoKey = CryptoKey.new()

enum Type {
	HMAC1,
	HMAC256,
	RSA256
}

func get_name() -> String:
	match _alg:
        # Note: HS1 is not secure and should be removed.
		Type.HMAC1: return "HSA1"
		Type.HMAC256: return "HS256"
		Type.RSA256: return "RS256"
		_: return ""


# @ctx_type: HashingContext.HashType
func _digest(ctx_type, data: PackedByteArray) -> PackedByteArray:
    var ctx: HashingContext = HashingContext.new()
    ctx.start(ctx_type)
    ctx.update(data)
    return ctx.finish()


func sign(text: String) -> PackedByteArray:
	var signature_bytes: PackedByteArray = []
	match self._alg:
		Type.HMAC1:
			signature_bytes = self.crypto.hmac_digest(HashingContext.HASH_SHA1, self._secret.to_utf8_buffer(), text.to_utf8_buffer())
		Type.HMAC256:
			signature_bytes = self.crypto.hmac_digest(HashingContext.HASH_SHA256, self._secret.to_utf8_buffer(), text.to_utf8_buffer())
		Type.RSA256:
			signature_bytes = self.crypto.sign(HashingContext.HASH_SHA256, text.sha256_buffer(), self._private_crypto)
	return signature_bytes


func verify(jwt: JWTDecoder) -> bool:
	var signature_bytes: PackedByteArray = []
	match self._alg:
		Type.HMAC1:
			signature_bytes = self.crypto.hmac_digest(HashingContext.HASH_SHA1, self._secret.to_utf8_buffer(), (jwt.parts[0]+"."+jwt.parts[1]).to_utf8_buffer())
		Type.HMAC256:
			signature_bytes = self.crypto.hmac_digest(HashingContext.HASH_SHA256, self._secret.to_utf8_buffer(), (jwt.parts[0]+"."+jwt.parts[1]).to_utf8_buffer())
		Type.RSA256:
			return self.crypto.verify(HashingContext.HASH_SHA256, (jwt.parts[0]+"."+jwt.parts[1]).sha256_buffer(), JWTUtils.base64URL_decode(jwt.parts[2]), self._public_crypto)
	return jwt.parts[2] == JWTUtils.base64URL_encode(signature_bytes)