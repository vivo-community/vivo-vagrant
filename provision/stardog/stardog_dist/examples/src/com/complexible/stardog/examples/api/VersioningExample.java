// Copyright (c) 2010 - 2012 -- Clark & Parsia, LLC. <http://www.clarkparsia.com>
// For more information about licensing and copyright of this software, please contact
// inquiries@clarkparsia.com or visit http://stardog.com

package com.complexible.stardog.examples.api;

import static com.complexible.common.rdf.model.Values.literal;
import static com.complexible.common.rdf.model.Values.namespace;
import static com.complexible.common.rdf.model.Values.uri;
import info.aduna.io.FileUtil;

import java.io.File;
import java.io.FileOutputStream;
import java.util.concurrent.TimeUnit;

import org.openrdf.model.URI;
import org.openrdf.model.vocabulary.DC;
import org.openrdf.model.vocabulary.FOAF;
import org.openrdf.model.vocabulary.RDF;
import org.openrdf.rio.RDFFormat;

import com.complexible.common.iterations.Iteration;
import com.complexible.common.protocols.server.Server;
import com.complexible.common.rdf.rio.RDFWriters;
import com.complexible.stardog.Contexts;
import com.complexible.stardog.Stardog;
import com.complexible.stardog.StardogException;
import com.complexible.stardog.api.ConnectionConfiguration;
import com.complexible.stardog.api.admin.AdminConnection;
import com.complexible.stardog.api.admin.AdminConnectionConfiguration;
import com.complexible.stardog.api.versioning.Version;
import com.complexible.stardog.api.versioning.VersioningConnection;
import com.complexible.stardog.db.DatabaseOptions;
import com.complexible.stardog.protocols.snarl.SNARLProtocolConstants;
import com.complexible.stardog.versioning.VersioningOptions;
import com.google.common.collect.Lists;
import com.google.common.io.Files;
import com.google.common.util.concurrent.Uninterruptibles;

/**
 * <p>Simple example for versioning</p>
 *
 * @author  Evren Sirin
 * @since   2.v
 * @version 2.v
 */
public class VersioningExample {
		private static final String NS = "http://example.org/test/";
		private static final URI Alice = uri(NS, "Alice");
		private static final URI Bob = uri(NS, "Bob");
		private static final URI Charlie = uri(NS, "Charlie");
	
	public static void main(String[] args) throws Exception {
		Server aServer = Stardog
			                 .buildServer()
			                 .bind(SNARLProtocolConstants.EMBEDDED_ADDRESS)
			                 .start();
		
		String aDB = "versionedDB";

		// first create a temporary database to use
		AdminConnection dbms = AdminConnectionConfiguration.toEmbeddedServer().credentials("admin", "admin").connect();

		// check whether there is no such database already, and if there is, drop it		
		if (dbms.list().contains(aDB)) {
			dbms.drop(aDB);
		}

		ConnectionConfiguration aConfig = dbms
			.disk(aDB)
		    .set(VersioningOptions.ENABLED, true)
		    .set(DatabaseOptions.NAMESPACES, Lists.newArrayList(namespace("", NS), namespace("foaf", FOAF.NAMESPACE), namespace("dc", DC.NAMESPACE)))
		    .create();

		dbms.close();

		// obtain a connection to the database and request a view of the connection as a versioning connection
		VersioningConnection aConn = aConfig.connect().as(VersioningConnection.class);

		// first things first, lets make some changes

		aConn.begin();
		aConn.add()
			.statement(Alice, DC.PUBLISHER, literal("Alice"))
			.statement(Bob, DC.PUBLISHER, literal("Bob"))
			.statement(Alice, RDF.TYPE, FOAF.PERSON, Alice)
			.statement(Alice, FOAF.MBOX, literal("mailto:alice@example.org"),  Alice)
			.statement(Bob, RDF.TYPE, FOAF.PERSON, Bob)
			.statement(Bob, FOAF.MBOX, literal("mailto:bob@example.org"), Bob);
		
		// committing our changes with a commit message
		aConn.commit("Adding Alice and Bob");
		
		Uninterruptibles.sleepUninterruptibly(2, TimeUnit.SECONDS);

		aConn.begin();
		aConn.remove().statements(Alice, FOAF.MBOX, literal("mailto:alice@example.org"),  Alice);
		aConn.add().statement(Alice, FOAF.MBOX, literal("mailto:alice@another.example.org"),  Alice);
		aConn.commit("Changing Alice's email");
		
RDFWriters.write(aConn.get().context(Contexts.ALL).iterator(), RDFFormat.TRIG, aConn.namespaces(), System.out);
		
		Uninterruptibles.sleepUninterruptibly(5, TimeUnit.SECONDS);
		
		aConn.begin();
		aConn.add()
			.statement(Charlie, DC.PUBLISHER, literal("Charlie"))
			.statement(Charlie, RDF.TYPE, FOAF.PERSON, Charlie)
			.statement(Charlie, FOAF.MBOX, literal("mailto:charlie@example.org"), Charlie);
		
		// we can still use the regular commit function from the Connection interface. This will also create a new
		// version along with its metadata but it will not have a commit message
		aConn.commit();
		
RDFWriters.write(aConn.get().context(Contexts.ALL).iterator(), RDFFormat.TRIG, aConn.namespaces(), System.out);



		// Lets try an example with the basic versioning API to list all versions
		Iteration<Version, StardogException> resultIt = aConn.versions().find().oldestFirst().iterator();

		System.out.println("\nVersions: ");
		while (resultIt.hasNext()) {
			Version aVersion = resultIt.next();

			System.out.println(aVersion);
		}

		// don't forget to close your iteration!
		resultIt.close();
		
		String aTag = "Release 1.0";
		Version aHeadVersion = aConn.versions().getHead();
		aConn.tags().create(aHeadVersion, aTag);
		
		System.out.println(aHeadVersion.getTags());

		System.out.println("Tagged " + aHeadVersion.getURI() + " " + aTag);	

		aConn.revert(aHeadVersion.getRelativeVersion(-2), aHeadVersion, "Undo last two commits");
		
RDFWriters.write(aConn.get().context(Contexts.ALL).iterator(), RDFFormat.TRIG, aConn.namespaces(), System.out);
		
		resultIt.close();
		
		// always close your connections when you're done
		aConn.close();

		// you MUST stop the server if you've started it!
		aServer.stop();
	}
}
