@file:OptIn(ExperimentalMaterial3Api::class)

package com.joelpedraza.giphrs.ui

import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarColors
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.material3.rememberTopAppBarState
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.joelpedraza.giphrs.R
import com.joelpedraza.giphrs.core.KotlinViewModel
import com.joelpedraza.giphrs.ui.theme.GiphyTheme
import com.joelpedraza.giphrs.ui.view.MainStateFlipper

class MainActivity : ComponentActivity() {
    private val viewModel by viewModels<KotlinViewModel>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            GiphyTheme {
                val items = viewModel.previewsFlow.collectAsStateWithLifecycle()
                val isLoading = viewModel.isLoadingFlow.collectAsStateWithLifecycle()
                val hasError = viewModel.hasErrorFlow.collectAsStateWithLifecycle()

                val topAppBarScrollBehavior =
                    TopAppBarDefaults.exitUntilCollapsedScrollBehavior(rememberTopAppBarState())

                Scaffold(
                    topBar = {
                        TopAppBar(
                            title = {
                                Text(
                                    text = stringResource(R.string.app_name),
                                    color = MaterialTheme.colorScheme.onPrimary,
                                    fontWeight = FontWeight.Black
                                )
                            },
                            colors =
                                TopAppBarColors(
                                    containerColor = MaterialTheme.colorScheme.primary,
                                    scrolledContainerColor = MaterialTheme.colorScheme.primaryContainer,
                                    navigationIconContentColor = MaterialTheme.colorScheme.onPrimaryContainer,
                                    titleContentColor = MaterialTheme.colorScheme.onPrimary,
                                    actionIconContentColor = MaterialTheme.colorScheme.onPrimary,
                                    subtitleContentColor = MaterialTheme.colorScheme.onPrimary
                                ),
                            scrollBehavior = topAppBarScrollBehavior,
                        )
                    },
                    modifier =
                        Modifier.fillMaxSize(),
                ) { innerPadding ->
                    PullToRefreshBox(
                        isRefreshing = isLoading.value,
                        onRefresh = { viewModel.refresh() },
                        modifier =
                            Modifier
                                .padding(innerPadding),
                        content = {
                            MainStateFlipper(
                                previews = items.value,
                                modifier = Modifier.fillMaxSize(),
                                hasError = hasError.value,
                                onSeen = { id -> viewModel.onSeen(id) },
                                onForcePageRequest = { viewModel.requestNextPage() }
                            )
                        },
                    )
                }
            }
        }
    }
}
