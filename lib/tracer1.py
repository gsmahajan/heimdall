from typing import Optional

import structlog
from jaeger_client import Config
from opentracing import Tracer
from opentracing.scope_managers.contextvars import ContextVarsScopeManager

logger = structlog.get_logger(__name__)

_tracer: Optional[Tracer] = None


def init_tracer(tracing_enabled,
                jaeger_service_name,
                jaeger_sampler_type,
                jaeger_sampler_param,
                jaeger_agent_host,
                jaeger_agent_port):
    global _tracer

    try:
        if tracing_enabled:
            jaeger_config = Config(
                config={
                    'sampler': {
                        'type': jaeger_sampler_type,
                        'param': jaeger_sampler_param,
                    },
                    'local_agent': {
                        'reporting_host': jaeger_agent_host,
                        'reporting_port': jaeger_agent_port,
                    },
                    'logging': True,
                },
                service_name=jaeger_service_name,
                # opentracing-python recommends to use ContextVarsScopeManager for asyncio applications
                # https://github.com/opentracing/opentracing-python
                scope_manager=ContextVarsScopeManager(),
            )
            # If Config.initialized is True, Jaeger won't try to initialize the tracer
            if Config.initialized():
                Config._initialized = False
            _tracer = jaeger_config.initialize_tracer()
            if _tracer is None:
                raise Exception("Jaeger Config initialize_tracer returned None.")
            logger.info("Jaeger Tracer initialized")
        else:
            _tracer = Tracer()
            logger.info("Tracer disabled.")
    except Exception as e:
        _tracer = Tracer()
        logger.warn("Couldn't load the Jaeger Tracer. Initializing with a NoopTracer", error=str(e))


def get_tracer() -> Optional[Tracer]:
    return _tracer
