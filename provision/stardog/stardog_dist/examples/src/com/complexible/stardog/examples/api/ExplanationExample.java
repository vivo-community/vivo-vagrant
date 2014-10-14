package com.complexible.stardog.examples.api;

import static com.complexible.common.openrdf.util.ExpressionFactory.type;

import org.openrdf.model.Statement;
import org.openrdf.model.URI;
import org.openrdf.model.impl.ValueFactoryImpl;
import org.openrdf.model.vocabulary.OWL;
import org.openrdf.model.vocabulary.RDF;
import org.openrdf.model.vocabulary.RDFS;

import com.complexible.common.openrdf.util.Expression;
import com.complexible.common.protocols.server.Server;
import com.complexible.stardog.Stardog;
import com.complexible.stardog.api.admin.AdminConnection;
import com.complexible.stardog.api.admin.AdminConnectionConfiguration;
import com.complexible.stardog.api.reasoning.ReasoningConnection;
import com.complexible.stardog.protocols.snarl.SNARLProtocolConstants;
import com.complexible.stardog.reasoning.Proof;
import com.complexible.stardog.reasoning.api.ReasoningType;
import com.complexible.stardog.reasoning.ExpressionWriter;
import com.complexible.stardog.reasoning.ProofWriter;

/**
 * <p>Simple example to show how to use Stardog's explanation facilities.</p>
 *
 * @author Michael Grove
 *
 * @since   0.7.3
 * @version 2.0
 *
 * @see Expression
 * @see com.complexible.common.openrdf.util.ExpressionFactory
 */
public class ExplanationExample {
    protected static final URI x = ValueFactoryImpl.getInstance().createURI("urn:x");
	protected static final URI y = ValueFactoryImpl.getInstance().createURI("urn:y");
	protected static final URI z = ValueFactoryImpl.getInstance().createURI("urn:z");
	protected static final URI A = ValueFactoryImpl.getInstance().createURI("urn:A");
	protected static final URI B = ValueFactoryImpl.getInstance().createURI("urn:B");
	protected static final URI C = ValueFactoryImpl.getInstance().createURI("urn:C");
	protected static final URI D = ValueFactoryImpl.getInstance().createURI("urn:D");
	protected static final URI p = ValueFactoryImpl.getInstance().createURI("urn:p");
	protected static final URI p1 = ValueFactoryImpl.getInstance().createURI("urn:p1");
	protected static final URI p2 = ValueFactoryImpl.getInstance().createURI("urn:p2");

    public static void main(String[] args) throws Exception {
        Server aServer = Stardog
            .buildServer()
            .bind(SNARLProtocolConstants.EMBEDDED_ADDRESS)
            .start();
		
    	AdminConnection aAdminConnection = AdminConnectionConfiguration.toEmbeddedServer().credentials("admin", "admin").connect();
    	
    	// drop the db if it already exists
    	if (aAdminConnection.list().contains("reasoningTest")) {
			aAdminConnection.drop("reasoningTest");
		}

        // first create a new, temporary in-memory db and then connect w/ RL reasoning
    	ReasoningConnection aReasoningConnection = 
    					aAdminConnection.memory("reasoningTest").create()
        	                   .credentials("admin", "admin")
        	                   .reasoning(ReasoningType.RL)
        	                   .connect()
        	                   .as(ReasoningConnection.class);
		
		// we can close the admin connection now that the db is created
		aAdminConnection.close();

        // add a simple schema and couple instance triples to the connection
        aReasoningConnection.begin();
        aReasoningConnection.add()
        		.statement(p, RDFS.DOMAIN, B)
        		.statement(B, RDFS.SUBCLASSOF, A)
                .statement(x, p , y)
                .statement(z, RDF.TYPE, B);
        aReasoningConnection.commit();

        // this is the statement we want to explain
        Statement aStmt = ValueFactoryImpl.getInstance().createStatement(z, RDF.TYPE, A);

        // lets look for it without reasoning
        boolean aExistsNoReasoning = aReasoningConnection.get()
        		.reasoning(ReasoningType.NONE)		
                .subject(z)
                .predicate(RDF.TYPE)
                .object(A)
                .ask();

        // it's not there since we're not using reasoning
        System.out.println("Exists without reasoning? " + aExistsNoReasoning);

        // but with the reasoning connection, we see that it exists
        boolean aExistsReasoning = aReasoningConnection.get()
                .subject(z)
                .predicate(RDF.TYPE)
                .object(A)
                .ask();

        System.out.println("Exists with reasoning? " + aExistsReasoning);

        // So lets find out why that statement was inferred by the reasoner.

        // Explanations are returned as a Set of Expressions.  Each Expression corresponds
        // to a single OWL axiom in the explanation.  The set of results makes up all the
        // axioms for a single explanation.

        Proof aExplanation = aReasoningConnection.explain(type(z, A)).proof();

        // Here we will see that the subClassOf axiom is responsible for the inference.
        System.out.println("\nExplain inference: ");
        System.out.println(ProofWriter.toString(aExplanation));

        // Another statement the reasoner will infer is (x, RDF.TYPE, A) using both of the
        // axioms in our tbox

        aStmt = ValueFactoryImpl.getInstance().createStatement(x, RDF.TYPE, A);

        aExplanation = aReasoningConnection.explain(type(x, A)).proof();

        System.out.println("Explain inference: ");
        System.out.println(ProofWriter.toString(aExplanation));
        
        // introduce a simple inconsistency in the db
        aReasoningConnection.begin();
        aReasoningConnection.add()
        		.statement(A, OWL.DISJOINTWITH, D)
                .statement(z, RDF.TYPE, D);
        aReasoningConnection.commit();
        
        // now explain the inconsistency
        Proof aProof = aReasoningConnection.explainInconsistency().proof();
        System.out.println("Explain inconsistency: ");
        System.out.println(ProofWriter.toString(aProof));
        
        System.out.println("Render only asserted statements: ");
        System.out.println(ExpressionWriter.toString(aProof.getStatements()));


        aReasoningConnection.close();

	    // you MUST stop the server if you've started it!
	    aServer.stop();
    }
}
