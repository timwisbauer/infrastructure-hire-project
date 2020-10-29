from flask import Flask
from requests import get

app = Flask(__name__)

@app.route('/test')
def health_check():
    return "it works"

@app.route('/vulns')
def vulnerability_proxy():
    """
    Sends get request to backend vulnerability service
    """
    return get('http://vulns-app.vulns-app/').content    

@app.route('/evil')
def evil_proxy():
    """
    A function to serve a generic nginx page
    """
    get("http://nginx")

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8081)

