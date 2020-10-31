from flask import Flask
from requests import get

app = Flask(__name__)

@app.route('/test')
def health_check():
    return "it works"

@app.route('/vulns')
def vulnerability_proxy():
    """
    Sends get request to backend vulnerability service for vulns endpoint.
    """
    return get('http://vulns-app.vulns-app/').content    

@app.route('/stats')
def stats_proxy():
    """
    Sends get request to backend vulnerability service for stats endpoint.
    """
    return get('http://vulns-app.vulns-app/stats').content    

@app.route('/evil')
def evil_proxy():
    """
    A function to serve a generic nginx page
    """
    return get("http://nginx").content

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8081)

