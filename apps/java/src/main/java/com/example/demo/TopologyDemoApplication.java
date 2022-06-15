package com.example.demo;

import io.opentelemetry.api.OpenTelemetry;
import io.opentelemetry.api.common.Attributes;
import io.opentelemetry.api.common.AttributesBuilder;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.StatusCode;
import io.opentelemetry.api.trace.Tracer;
import io.opentelemetry.api.trace.propagation.W3CTraceContextPropagator;
import io.opentelemetry.context.Context;
import io.opentelemetry.context.Scope;
import io.opentelemetry.context.propagation.ContextPropagators;
import io.opentelemetry.exporter.otlp.trace.OtlpGrpcSpanExporter;
import io.opentelemetry.sdk.OpenTelemetrySdk;
import io.opentelemetry.sdk.resources.Resource;
import io.opentelemetry.sdk.trace.SdkTracerProvider;
import io.opentelemetry.sdk.trace.export.BatchSpanProcessor;
import io.opentelemetry.semconv.resource.attributes.ResourceAttributes;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.context.ServletWebServerInitializedEvent;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.event.EventListener;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;

import java.util.HashSet;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;
import java.util.concurrent.TimeUnit;

@Controller
@Configuration
@SpringBootApplication
@RequestMapping(path = "/")
public class TopologyDemoApplication {

	private static Integer myPort = 0;

	@EventListener
	public void onApplicationEvent(final ServletWebServerInitializedEvent event) {
		myPort = event.getWebServer().getPort();
	}

	static Tracer tracer;

	static {
		AttributesBuilder attrBuilders = Attributes.builder()
				.put(ResourceAttributes.SERVICE_NAME, System.getProperty("otel.resource.attributes", "demo_x"))
				.put(ResourceAttributes.SERVICE_NAMESPACE, "US-West-2")
				.put(ResourceAttributes.HOST_NAME, System.getProperty("otel.resource.attributes", "foobar"));

		Resource serviceResource = Resource.create(attrBuilders.build());
		OtlpGrpcSpanExporter spanExporter = OtlpGrpcSpanExporter.builder()
				.setEndpoint(System.getProperty("otel.exporter.otlp.endpoint", "http://localhost:4317"))
				.build();

		SdkTracerProvider sdkTracerProvider = SdkTracerProvider.builder()
				.addSpanProcessor(BatchSpanProcessor.builder(spanExporter)
						.setScheduleDelay(100, TimeUnit.MILLISECONDS).build())
				.setResource(serviceResource)
				.build();

		OpenTelemetry openTelemetry = OpenTelemetrySdk.builder()
				.setTracerProvider(sdkTracerProvider)
				.setPropagators(ContextPropagators.create(W3CTraceContextPropagator.getInstance())).build();

		tracer = openTelemetry.getTracer(System.getProperty("host.name", "localhost") + "-instrumentation");

	}

//	static{
//		SdkTracerProvider sdkTracerProvider = SdkTracerProvider.builder()
//				.addSpanProcessor(BatchSpanProcessor.builder(OtlpGrpcSpanExporter.builder().build()).build())//NoopSpanExporter
//				.build();
//
//		OpenTelemetry openTelemetry = OpenTelemetrySdk.builder()
//				.setTracerProvider(sdkTracerProvider)
//				.setPropagators(ContextPropagators.create(W3CTraceContextPropagator.getInstance()))
//				.buildAndRegisterGlobal();
//		tracer = openTelemetry.getTracer("topology-psr-instrumentation");
//
//	}

	public static void main(String[] args) {
		SpringApplication.run(TopologyDemoApplication.class, args);
	}

	public static String ports_lists = System.getProperty("ports_list", "12000-12030");
	public static String hosts_lists = System.getProperty("hosts_list", "logistics,automobile,pharmacy");

	//public static String hosts_lists = System.getProperty("hosts_list", "10.55.13.6,10.55.13.227,10.55.13.130");

	@RequestMapping("/random")
	public @ResponseBody
	ResponseEntity<String> getRandom() {
		System.out.println("My Port => "+myPort);
		if(tracer !=null) {
			Span parentSpan = tracer.spanBuilder("random_apm_generator_").startSpan();

			try (Scope scope = parentSpan.makeCurrent()) {

				Set<Integer> portSet = getPortSet(ports_lists);
				// messing up to topology connections for spans to be visible randomly
				int maxCount = ThreadLocalRandom.current().nextInt(1, portSet.size() / 6);
				try {
					portSet.stream().limit(maxCount).forEach(port -> {
						if (port != myPort) {
							// lets make a random 3-5 ports (any) call here as child spans
							System.out.println("Running child span by myPort=" + myPort + " to child => port=" + port);
							runChildSpan(port, parentSpan);
						}
					});
				}catch(Exception e){
					//ignore
				}

				try {
					portSet.stream().limit(maxCount).forEach(port -> {
						if (port != myPort) {
							// lets make a random 3-5 ports (any) call here as child spans
							System.out.println("Running child span by myPort=" + myPort + " to child => port=" + port);
							runChildSpanLocal(port, parentSpan);
						}
					});
				}catch(Exception e){
					//ignore
				}

				return ResponseEntity.ok(String.valueOf(ThreadLocalRandom.current().nextInt(10, 2000)));
			} catch (Exception e) {
				parentSpan.setStatus(StatusCode.ERROR, "Error in calling service root call demo_x");
			} finally {
				parentSpan.end();
			}
		}
		return ResponseEntity.ok("tracing setup error");
	}

	public Set<Integer> getPortSet(String input){
		String [] foo = input.split("-");
		
		Integer begin = Integer.parseInt(foo[0]);
		Integer end = Integer.parseInt(foo[1]);

		Set<Integer> portsResult = new HashSet<>();
		for (int i = begin; i <= end; ++i){
			portsResult.add(i);
		}
		return portsResult;
	}

	public void runChildSpanLocal(Integer port, Span parentSpan){
		Span childSpan = tracer.spanBuilder("child_port_calling")
				.setParent(Context.current().with(parentSpan))
				.startSpan();
		try {
			childSpan.setStatus(StatusCode.OK);
			// self loop topology hiding
			RestTemplate restTemplate = new RestTemplate();
			String output = restTemplate.getForObject("http://localhost:" + port + "/apm/random?requestId=" + UUID.randomUUID().toString(), String.class);
			System.out.println("port=" + port + " returns output " + output);
		} catch (Exception g) {
			childSpan.setStatus(StatusCode.ERROR, "error calling internal APIs");
		} finally {
			childSpan.end();
		}
	}

	public void runChildSpan(Integer port, Span parentSpan){
		Span childSpan = tracer.spanBuilder("child_port_calling")
				.setParent(Context.current().with(parentSpan))
				.startSpan();
		try {
			childSpan.setStatus(StatusCode.OK);
			// self loop topology hiding
			RestTemplate restTemplate = new RestTemplate();
			String output = restTemplate.getForObject("http://"+hosts_lists.split(",")[port%3] + ":" + port + "/apm/random?requestId=" + UUID.randomUUID().toString(), String.class);
			System.out.println("port=" + port + " returns output " + output);
		} catch (Exception g) {
			childSpan.setStatus(StatusCode.ERROR, "error calling internal APIs");
		} finally {
			childSpan.end();
		}
	}
}
