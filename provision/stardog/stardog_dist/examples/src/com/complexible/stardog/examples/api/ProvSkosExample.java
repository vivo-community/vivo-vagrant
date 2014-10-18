// Copyright (c) 2010 - 2013, Clark & Parsia, LLC. <http://www.clarkparsia.com>
// For more information about licensing and copyright of this software, please contact
// inquiries@clarkparsia.com or visit http://stardog.com

package com.complexible.stardog.examples.api;

import java.util.Arrays;

import com.complexible.common.protocols.server.Server;
import com.complexible.stardog.protocols.snarl.SNARLProtocolConstants;
import org.openrdf.model.Resource;
import org.openrdf.model.URI;
import org.openrdf.model.vocabulary.DC;
import org.openrdf.model.vocabulary.RDF;
import org.openrdf.model.vocabulary.SKOS;
import org.openrdf.query.resultio.QueryResultIO;

import com.complexible.common.openrdf.vocabulary.Vocabulary;
import com.complexible.common.rdf.model.Values;
import com.complexible.common.rdf.query.resultio.TextTableQueryResultWriter;
import com.complexible.stardog.ContextSets;
import com.complexible.stardog.Stardog;
import com.complexible.stardog.api.ConnectionConfiguration;
import com.complexible.stardog.api.Connection;
import com.complexible.stardog.api.SelectQuery;
import com.complexible.stardog.api.admin.AdminConnection;
import com.complexible.stardog.api.admin.AdminConnectionConfiguration;
import com.complexible.stardog.db.DatabaseOptions;
import com.complexible.stardog.icv.api.ICVConnection;
import com.complexible.stardog.prov.ProvVocabulary;
import com.complexible.stardog.reasoning.api.ReasoningType;

/**
 * <p>Example code illustrating use of the built-in ontologies in Stardog, specifically for PROV and SKOS ontologies.</p>
 *
 * @author  Evren Sirin
 * @since   2.0
 * @version 2.0
 */
public class ProvSkosExample {
	// Very simple publication vocabulary used in this example
	public static class PublicationVocabulary extends Vocabulary {
		public static final PublicationVocabulary INSTANCE = new PublicationVocabulary();
		
		public PublicationVocabulary() {
	        super("urn:example:publication:");
        }
		
		public URI Book = term("Book");
		public URI Fiction = term("Fiction");
		public URI ScienceFiction = term("ScienceFiction");
		
		public URI Author = term("Author");
	}
	
	// Define constants for vocabularies that we will use
	public static final PublicationVocabulary PUB = PublicationVocabulary.INSTANCE;	
	public static final ProvVocabulary PROV = ProvVocabulary.INSTANCE;

	public static void main(String[] args) throws Exception {
        Server aServer = Stardog.buildServer()
               .bind(SNARLProtocolConstants.EMBEDDED_ADDRESS).start();

		aServer.start();

		String db = "exampleProvSkos";
		
		// first create a temporary database to use (if there is one already, drop it first)
		AdminConnection dbms = AdminConnectionConfiguration.toEmbeddedServer().credentials("admin", "admin").connect();
		if (dbms.list().contains(db)) {
			dbms.drop(db);
		}
		
		// enable both PROV and SKOS ontologies for the current database
		dbms.memory(db).set(DatabaseOptions.ARCHETYPES, Arrays.asList("skos", "prov")).create();
		
		dbms.close();
		
		// obtain a connection to the database
		Connection aConn = ConnectionConfiguration
			.to(db)       // the name of the db to connect to
			.credentials("admin", "admin") // credentials with which to connect
			.reasoning(ReasoningType.RL)
			.connect();				       // now open the connection

		// first create the SKOS schema and introduce an error (related and transitive broader relations should be disjoint)
		aConn.begin();
		aConn.add()
			.statement(PUB.Book, RDF.TYPE, SKOS.CONCEPT)
			.statement(PUB.Fiction, RDF.TYPE, SKOS.CONCEPT)
			.statement(PUB.ScienceFiction, RDF.TYPE, SKOS.CONCEPT)
			.statement(PUB.Book, SKOS.NARROWER, PUB.Fiction)
			.statement(PUB.ScienceFiction, SKOS.BROADER, PUB.Fiction)
			.statement(PUB.ScienceFiction, SKOS.RELATED, PUB.Book);
		aConn.commit();
		
		// let's validate the SKOS schema, note that SKOS inferences and constraints are automatically included in the database 
		ICVConnection aValidator = aConn.as(ICVConnection.class);

		// for simplicity, we will just print that the data is not valid (explanations can be retrieved separately) 
		System.out.println("The data " + (aValidator.isValid(ContextSets.DEFAULT_ONLY) ? "is" : "is NOT") + " valid!");
		
		// let's remove the problematic triple and add some PROV data
		URI The_War_of_the_Worlds = Values.uri("http://dbpedia.org/resource/The_War_of_the_Worlds");
		URI H_G_Wells = Values.uri("http://dbpedia.org/resource/H._G._Wells");
		Resource attr = Values.bnode();
		aConn.begin();
		aConn.remove()
			.statements(PUB.ScienceFiction, SKOS.RELATED, PUB.Book);
		aConn.add()
			.statement(The_War_of_the_Worlds, RDF.TYPE, PROV.Entity)
			.statement(The_War_of_the_Worlds, DC.SUBJECT, PUB.ScienceFiction)
			.statement(The_War_of_the_Worlds, PROV.qualifiedAttribution, attr)
			.statement(attr, RDF.TYPE, PROV.Attribution)
			.statement(attr, PROV.agent, H_G_Wells)
			.statement(attr, PROV.hadRole, PUB.Author);
		aConn.commit();

		// now that the problematic triples is removed, the data will be valid
		System.out.println("The data " + (aValidator.isValid(ContextSets.DEFAULT_ONLY) ? "is" : "is NOT") + " valid!");
		
		// run a query that will retrieve all fiction books and their authors
		// this query uses both PROV and SKOS inferences that are automatically included
		// Using Book -[skos:narrower]-> Fiction <-[skos:broader]- ScienceFiction triples, we infer ScienceFiction -[skos:broaderTransitive]-> Book
		// Using The_War_of_the_Worlds -[prov:qualifiedAttribution]-> :_attr -[prov:agent]-> H_G_Wells, we infer The_War_of_the_Worlds -[prov:wasAttributedTo]-> H_G_Wells
		// also note that we don't need to define prefixes for skos and prov which are automatically registered to the database
		SelectQuery aQuery = aConn.select(
						 "PREFIX pub: <" + PUB.uri() + ">" +
						 "PREFIX dc: <" + DC.NAMESPACE + ">" +
						 "SELECT * WHERE {\n" +
						 "  ?book dc:subject/skos:broaderTransitive pub:Book;\n" +
						 "        prov:wasAttributedTo ?author\n" +
						 "}");

		// print the query results
		QueryResultIO.write(aQuery.execute(), TextTableQueryResultWriter.FORMAT, System.out);

		// always close your connections when you are done with them
		aConn.close();

		// you MUST stop the server if you've started it!
		aServer.stop();
	}
}
