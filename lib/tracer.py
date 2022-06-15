from opentelemetry import trace
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from opentelemetry.sdk.trace import TracerProvider
import topology_service.portal.run_portal
from opentelemetry.sdk.trace.export import (
    ConsoleSpanExporter,
    SimpleSpanProcessor,
)
 
trace.set_tracer_provider(TracerProvider())
trace.get_tracer_provider().add_span_processor(
    SimpleSpanProcessor(ConsoleSpanExporter())
)
 
app = topology_service.portal.run_portal.create_app()
FlaskInstrumentor().instrument_app(app)
RequestsInstrumentor().instrument()
 
 
if __name__ == "__main__":
    app.run(debug=True, port=5000)
