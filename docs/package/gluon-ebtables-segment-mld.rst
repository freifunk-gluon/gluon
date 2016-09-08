gluon-ebtables-segment-mld
==========================

These filters drop IGMP/MLD packets before they enter the mesh and
filter any IGMP/MLD packets coming from the mesh.

IGMP/MLD have the concept of a local, elected Querier. For more
decentralization and increased robustness, the idea of this package is
to split the IGMP/MLD domain a querier is responsible for, allowing to
have a querier per node. The split IGMP/MLD domain will also reduce
overhead for this packet type, increasing scalability.

Beware of the consequences of using this package though: You might need
to explicitly, manually mark ports on snooping switches leading towards
your mesh node as multicast router ports for now (Multicast Router
Discovery, MRD, not implemented yet).
