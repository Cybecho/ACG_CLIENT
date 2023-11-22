import socket

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# 서버의 IP 주소와 포트 번호를 튜플로 지정
server_address = ('ec2-34-207-178-168.compute-1.amazonaws.com', <PORT NUMBER>)

sock.connect(server_address)  # 서버와의 연결 시도

# 클라이언트의 현재 디렉토리에 있는 hello.txt 파일을 열고 읽어옴
with open('hello.txt', 'rb') as file:
    data = file.read()

sock.send(data)  # 서버에 데이터를 전송
