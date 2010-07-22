/*
 * Copyright 2010 (c) Dominic Graefen, devboy.org.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

package org.devboy.toolkit.net.p2p
{
    import flash.events.NetStatusEvent;
    import flash.net.GroupSpecifier;
    import flash.net.NetConnection;
    import flash.utils.getTimer;

    public class P2PCommandChannel extends P2PChannel
    {
        private var _netConnection : NetConnection;
        private var _user : P2PUser;

        public function P2PCommandChannel(netConnection : NetConnection, p2pUser : P2PUser, channelGroupID : String)
        {
            super(channelGroupID);
            _netConnection = netConnection;
            _user = p2pUser;
            init();
        }

        private function init() : void
        {
            var groupSpecifier : GroupSpecifier = new GroupSpecifier(groupID);
            groupSpecifier.serverChannelEnabled = true;
            groupSpecifier.postingEnabled = true;
            connect(_netConnection, groupSpecifier, true);
        }

        override protected function netStatus(e : NetStatusEvent) : void {
            super.netStatus(e);
            switch (e.info.code)
            {
                case NetStatusCodes.NETGROUP_POSTING_NOTIFY:
                    receiveCommand(P2PCommand.createFromObject(e.info.message));
                    break;
            }
        }

        private function receiveCommand(command : P2PCommand) : void
        {
            //Output.output("P2PCommandChannel->receiveCommand");
            dispatchEvent(new P2PCommandEvent(P2PCommandEvent.RECEIVE_COMMAND, command));
        }

        public function postCommand(commandType : String, commandParams : Array) : void
        {
            //Output.output("P2PCommandChannel->postCommand");
            var cmd : P2PCommand = new P2PCommand(commandType, commandParams, _user.userName, getTimer());
            netGroup.post(cmd.createObject());
        }

        public function postCommandToAllNeighbors(commandType : String, commandParams : Array) : void
        {
            //Output.output("P2PCommandChannel->postCommand");
            var cmd : P2PCommand = new P2PCommand(commandType, commandParams, _user.userName, getTimer());
            netGroup.sendToAllNeighbors(cmd);
        }
    }
}