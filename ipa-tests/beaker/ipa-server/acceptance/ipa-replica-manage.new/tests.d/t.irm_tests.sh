irm_run()
{
    irm_version_pos_0001 # version

    irm_list_pos_0001 # list, no name
    irm_list_pos_0002 # list, with name
    # irm_list_pos_0003 # list, no name, with verbose
    # irm_list_pos_0004 # list, with name, with verbose
    # irm_list_pos_0005 # list, with name, remote
    # irm_list_neg_0001 # list fail, no agreement, with name
    # irm_list_neg_0002 # list fail, no agreement, with name, remote
    # irm_list_neg_0003 # list fail, non-existent host, with name
    # irm_list_neg_0004 # list fail, after uninstalling replica, with name [BZ#754739]

    # irm_disconnect_pos_0001 # disconnect, master to replica2 agreement
    # irm_disconnect_pos_0002 # disconnect, master to replica2 agreement, remote
    # irm_disconnect_neg_0001 # disconnect fail, replica with last agreement
    # irm_disconnect_neg_0002 # disconnect fail, replica with last agreement, remote
    # irm_disconnect_neg_0003 # disconnect fail, non-existent replica
    # irm_disconnect_neg_0004 # disconnect fail, non-existent replica, remote
    # irm_disconnect_neg_0005 # disconnect fail, after already disconnected
    # irm_disconnect_neg_0006 # disconnect fail, after already disconnected, remote

    # irm_connect_pos_0001 # connect, replica1 to replica4
    # irm_connect_pos_0002 # connect, replica1 to replica4, remote
    # irm_connect_neg_0001 # connect fail, existing agreement
    # irm_connect_neg_0002 # connect fail, existing agreement, remote

    # irm_forcesync_pos_0001 # forcesync, master from replica1
    # irm_forcesync_pos_0002 # forcesync, master from replica1, remote
    # irm_forcesync_pos_0003 # forcesync, replica2 from replica3
    # irm_forcesync_pos_0004 # forcesync, replica2 from replica3, remote
    # irm_forcesync_pos_0005 # forcesync, replica3 from replica4
    # irm_forcesync_pos_0006 # forcesync, replica3 from replica4, remote
    # irm_forcesync_neg_0001 # forcesync fail, without --from
    # irm_forcesync_neg_0002 # forcesync fail, without --from, remote
    # irm_forcesync_neg_0003 # forcesync fail, from self
    # irm_forcesync_neg_0004 # forcesync fail, from self, remote
    # irm_forcesync_neg_0005 # forcesync fail, from non-existent replica
    # irm_forcesync_neg_0006 # forcesync fail, from non-existent replica, remote
    # irm_forcesync_neg_0007 # forcesync fail, with no agreement
    # irm_forcesync_neg_0008 # forcesync fail, with no agreement, remote

    # irm_reinitialize_pos_0001 # reinitialize, master from replica1 [BZ#831661]
    # irm_reinitialize_pos_0002 # reinitialize, replica2 from master, remote [BZ#831661]
    # irm_reinitialize_pos_0003 # reinitialize, replica3 from replica2 [BZ#831661]
    # irm_reinitialize_pos_0004 # reinitialize, replica4 from replica3, remote [BZ#831661]
    # irm_reinitialize_neg_0001 # reinitialize fail, without --from
    # irm_reinitialize_neg_0002 # reinitialize fail, without --from, remote
    # irm_reinitialize_neg_0003 # reinitialize fail, from self
    # irm_reinitialize_neg_0004 # reinitialize fail, from self, remote
    # irm_reinitialize_neg_0005 # reinitialize fail, from non-existent replica
    # irm_reinitialize_neg_0006 # reinitialize fail, from non-existent replica, remote
    # irm_reinitialize_neg_0007 # reinitialize fail, with no agreement
    # irm_reinitialize_neg_0008 # reinitialize fail, with no agreement, remote

    # irm_del_pos_0001 # del, replica4
    # irm_del_pos_0002 # del, replica4, remote
    # irm_del_neg_0001 # del fail, with disconnected agreement
    # irm_del_neg_0002 # del fail, with disconnected agreement, remote
    # irm_del_neg_0003 # del fail, already deleted agreement [BZ#754524]
    # irm_del_neg_0004 # del fail, already deleted agreement, remote [BZ#754524]
    # irm_del_neg_0005 # del fail, non-existent replica
    # irm_del_neg_0006 # del fail, non-existent replica, remote
}
