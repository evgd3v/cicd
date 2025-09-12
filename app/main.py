from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
import datetime
import time

start_time = time.time()

app = FastAPI(docs_url=None, redoc_url=None, openapi_url=None)

app.mount("/static", StaticFiles(directory="static"), name="static")

templates = Jinja2Templates(directory="templates")

def get_uptime():
    """Calculate the server uptime since startup"""
    current_time = time.time()
    uptime_seconds = int(current_time - start_time)
    
    days, remainder = divmod(uptime_seconds, 86400)
    hours, remainder = divmod(remainder, 3600)
    minutes, seconds = divmod(remainder, 60)
    
    if days > 0:
        return f"{days}д {hours}ч {minutes}м {seconds}с"
    elif hours > 0:
        return f"{hours}ч {minutes}м {seconds}с"
    elif minutes > 0:
        return f"{minutes}м {seconds}с"
    else:
        return f"{seconds}с"

@app.exception_handler(404)
async def not_found_exception_handler(request: Request, exc: HTTPException):
    return templates.TemplateResponse("404.html", {"request": request}, status_code=404)

@app.get("/api/uptime")
def get_uptime_api():
    """API endpoint to get current server uptime"""
    return {"uptime": get_uptime()}

@app.get("/", response_class=HTMLResponse)
def root(request: Request):
    uptime = get_uptime()
    return templates.TemplateResponse("index.html", {"request": request, "uptime": uptime})