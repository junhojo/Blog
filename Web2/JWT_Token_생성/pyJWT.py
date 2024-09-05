import jwt   # PyJWT 
import uuid
import sys

def generate_authorization_token(access_key: str, secret_key: str) -> str:
    # payload 생성
    payload = {
        'access_key': access_key,
        'nonce': str(uuid.uuid4()),  # 고유한 nonce 값 생성
    }

    # JWT 토큰 생성
    jwt_token = jwt.encode(payload, secret_key, algorithm='HS256')

    # Authorization 토큰 생성
    authorization_token = f'Bearer {jwt_token}'
    return authorization_token

def main():
    if len(sys.argv) != 3:
        print("Usage: python3 pyJWT.py <access_key> <secret_key>")
        sys.exit(1)

    access_key = sys.argv[1]
    secret_key = sys.argv[2]

    authorization_token = generate_authorization_token(access_key, secret_key)
    print(authorization_token)

if __name__ == "__main__":
    main()