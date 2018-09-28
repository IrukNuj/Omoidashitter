import React, { Component } from 'react';
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import { AppBar, MenuItem, Drawer } from 'material-ui';

class NavBar_App extends Component {
    render() {
        return (
            <MuiThemeProvider>
                <div>
                    <Drawer
                        docked={false}
                        width={200}
                        open={this.props.open}
                        onRequestChange={() => this.props.onToggle()}
                    >
                        <MenuItem>とくに</MenuItem>
                        <MenuItem>意味は</MenuItem>
                        <MenuItem>無いけど</MenuItem>
                        <MenuItem>ハンバーガーボタン</MenuItem>
                        <MenuItem>作ってみたよ</MenuItem>
                    </Drawer>
                    <AppBar
                        title="Omoidashitter"
                        onLeftIconButtonClick={ () => this.props.onToggle()}
                    />
                </div>
            </MuiThemeProvider>
        );
    }
}

class NavBar extends Component {
    constructor() {
        super()
        this.state = {
            open: false
        }
    }
    handleToggle() {
        this.setState({
            open: !this.state.open
        })
    }
    render() {
        return (
            <div>
                <NavBar_App
                    onToggle={() => this.handleToggle()}
                    open={this.state.open}
                />
            </div>
        );
    }
}

export default NavBar;